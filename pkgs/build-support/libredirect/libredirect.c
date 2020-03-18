#define _GNU_SOURCE
#include <dlfcn.h>
#include <fcntl.h>
#include <limits.h>
#include <spawn.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

#define MAX_REDIRECTS 128

static int nrRedirects = 0;
static char *from[MAX_REDIRECTS];
static char *to[MAX_REDIRECTS];

// FIXME: might run too late.
static void init() __attribute__((constructor));

static int (*open_real)(const char *, int, mode_t);
static int (*open64_real)(const char *, int, mode_t);
static int (*openat_real)(int, const char *, int, mode_t);
static FILE *(*fopen_real)(const char *, const char *);
static FILE *(*fopen64_real)(const char *, const char *);
static int (*__xstat_real)(int ver, const char *, struct stat *);
static int (*__xstat64_real)(int ver, const char *, struct stat64 *);
static int (*stat_real)(const char *, struct stat *);
static int (*access_real)(const char *, int mode);
static int (*posix_spawn_real)(pid_t *, const char *,
                               const posix_spawn_file_actions_t *,
                               const posix_spawnattr_t *, char *const argv[],
                               char *const envp[]);
static int (*posix_spawnp_real)(pid_t *, const char *,
                                const posix_spawn_file_actions_t *,
                                const posix_spawnattr_t *, char *const argv[],
                                char *const envp[]);
static int (*execv_real)(const char *path, char *const argv[]);

static void init() {
  char *spec = getenv("NIX_REDIRECTS");
  if (!spec)
    return;

  unsetenv("NIX_REDIRECTS");

  char *spec2 = malloc(strlen(spec) + 1);
  strcpy(spec2, spec);

  char *pos = spec2, *eq;
  while ((eq = strchr(pos, '='))) {
    *eq = 0;
    from[nrRedirects] = pos;
    pos = eq + 1;
    to[nrRedirects] = pos;
    nrRedirects++;
    if (nrRedirects == MAX_REDIRECTS)
      break;
    char *end = strchr(pos, ':');
    if (!end)
      break;
    *end = 0;
    pos = end + 1;
  }

#define INIT(name)                                                             \
  do {                                                                         \
    name##_real = dlsym(RTLD_NEXT, #name);                                     \
  } while (0)
  INIT(open);
  INIT(open64);
  INIT(fopen);
  INIT(fopen64);
  INIT(__xstat);
  INIT(__xstat64);
  INIT(stat);
  INIT(access);
  INIT(posix_spawn);
  INIT(posix_spawnp);
  INIT(execv);
#undef INIT
}

static const char *rewrite(const char *path, char *buf) {
  if (path == NULL)
    return path;
  for (int n = 0; n < nrRedirects; ++n) {
    int len = strlen(from[n]);
    if (strncmp(path, from[n], len) != 0)
      continue;
    if (snprintf(buf, PATH_MAX, "%s%s", to[n], path + len) >= PATH_MAX)
      abort();
    return buf;
  }

  return path;
}

static int open_needs_mode(int flags) {
#ifdef O_TMPFILE
  return (flags & O_CREAT) || (flags & O_TMPFILE) == O_TMPFILE;
#else
  return flags & O_CREAT;
#endif
}

/* The following set of Glibc library functions is very incomplete -
   it contains only what we needed for programs in Nixpkgs. Just add
   more functions as needed. */

int open(const char *path, int flags, ...) {
  mode_t mode = 0;
  if (open_needs_mode(flags)) {
    va_list ap;
    va_start(ap, flags);
    mode = va_arg(ap, mode_t);
    va_end(ap);
  }
  char buf[PATH_MAX];
  return open_real(rewrite(path, buf), flags, mode);
}

int open64(const char *path, int flags, ...) {
  mode_t mode = 0;
  if (open_needs_mode(flags)) {
    va_list ap;
    va_start(ap, flags);
    mode = va_arg(ap, mode_t);
    va_end(ap);
  }
  char buf[PATH_MAX];
  return open64_real(rewrite(path, buf), flags, mode);
}

int openat(int dirfd, const char *path, int flags, ...) {
  mode_t mode = 0;
  if (open_needs_mode(flags)) {
    va_list ap;
    va_start(ap, flags);
    mode = va_arg(ap, mode_t);
    va_end(ap);
  }
  char buf[PATH_MAX];
  return openat_real(dirfd, rewrite(path, buf), flags, mode);
}

FILE *fopen(const char *path, const char *mode) {
  char buf[PATH_MAX];
  return fopen_real(rewrite(path, buf), mode);
}

FILE *fopen64(const char *path, const char *mode) {
  char buf[PATH_MAX];
  return fopen64_real(rewrite(path, buf), mode);
}

int __xstat(int ver, const char *path, struct stat *st) {
  char buf[PATH_MAX];
  return __xstat_real(ver, rewrite(path, buf), st);
}

int __xstat64(int ver, const char *path, struct stat64 *st) {
  char buf[PATH_MAX];
  return __xstat64_real(ver, rewrite(path, buf), st);
}

int stat(const char *path, struct stat *st) {
  char buf[PATH_MAX];
  return stat_real(rewrite(path, buf), st);
}

int access(const char *path, int mode) {
  char buf[PATH_MAX];
  return access_real(rewrite(path, buf), mode);
}

int posix_spawn(pid_t *pid, const char *path,
                const posix_spawn_file_actions_t *file_actions,
                const posix_spawnattr_t *attrp, char *const argv[],
                char *const envp[]) {
  char buf[PATH_MAX];
  return posix_spawn_real(pid, rewrite(path, buf), file_actions, attrp, argv,
                          envp);
}

int posix_spawnp(pid_t *pid, const char *file,
                 const posix_spawn_file_actions_t *file_actions,
                 const posix_spawnattr_t *attrp, char *const argv[],
                 char *const envp[]) {
  char buf[PATH_MAX];
  return posix_spawnp_real(pid, rewrite(file, buf), file_actions, attrp, argv,
                           envp);
}

int execv(const char *path, char *const argv[]) {
  char buf[PATH_MAX];
  return execv_real(rewrite(path, buf), argv);
}
