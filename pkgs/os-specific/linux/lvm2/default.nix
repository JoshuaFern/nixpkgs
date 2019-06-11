{ stdenv, fetchgit, fetchpatch, pkgconfig, systemd, udev, utillinux, libuuid
, thin-provisioning-tools, libaio
, enable_dmeventd ? false }:

stdenv.mkDerivation rec {
  pname = "lvm2";
  version = "2.03.04";

  src = fetchgit {
    url = "git://sourceware.org/git/lvm2.git";
    rev = "v${builtins.replaceStrings [ "." ] [ "_" ] version}";
    sha256 = "1fq7yc4ay42vd89r9hzi2vn2wf76vg8w23if7ybw72jpan0hz60z";
  };

  configureFlags = [
    "--disable-readline"
    "--enable-udev_rules"
    "--enable-udev_sync"
    "--enable-pkgconfig"
    "--enable-applib"
    "--enable-cmdlib"
  ] ++ stdenv.lib.optional enable_dmeventd " --enable-dmeventd"
  ++ stdenv.lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "ac_cv_func_malloc_0_nonnull=yes"
    "ac_cv_func_realloc_0_nonnull=yes"
  ];

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ udev libuuid thin-provisioning-tools libaio ];

  preConfigure =
    ''
      substituteInPlace scripts/lvm2_activation_generator_systemd_red_hat.c \
        --replace /usr/bin/udevadm ${systemd}/bin/udevadm

      sed -i /DEFAULT_SYS_DIR/d Makefile.in
      sed -i /DEFAULT_PROFILE_DIR/d conf/Makefile.in
    '';

  # gcc: error: ../../device_mapper/libdevice-mapper.a: No such file or directory
  enableParallelBuilding = false;

  # Patches safe on all, but limit to musl for now
  patches = stdenv.lib.optionals stdenv.hostPlatform.isMusl [
    (fetchpatch {
      name = "fix-stdio-usage.patch";
      url = "https://git.alpinelinux.org/cgit/aports/plain/main/lvm2/fix-stdio-usage.patch?h=3.7-stable&id=31bd4a8c2dc00ae79a821f6fe0ad2f23e1534f50";
      sha256 = "0m6wr6qrvxqi2d2h054cnv974jq1v65lqxy05g1znz946ga73k3p";
    })
    (fetchpatch {
      name = "mallinfo.patch";
      url = "https://git.alpinelinux.org/cgit/aports/plain/main/lvm2/mallinfo.patch?h=3.7-stable&id=31bd4a8c2dc00ae79a821f6fe0ad2f23e1534f50";
      sha256 = "0g6wlqi215i5s30bnbkn8w7axrs27y3bnygbpbnf64wwx7rxxlj0";
    })
    (fetchpatch {
      name = "mlockall-default-config.patch";
      url = "https://git.alpinelinux.org/cgit/aports/plain/main/lvm2/mlockall-default-config.patch?h=3.7-stable&id=31bd4a8c2dc00ae79a821f6fe0ad2f23e1534f50";
      sha256 = "1ivbj3sphgf8n1ykfiv5rbw7s8dgnj5jcr9jl2v8cwf28lkacw5l";
    })
  ];

  doCheck = false; # requires root

  # To prevent make install from failing.
  installFlags = [ "OWNER=" "GROUP=" "confdir=${placeholder "out"}/etc" ];

  # Install systemd stuff.
  #installTargets = "install install_systemd_generators install_systemd_units install_tmpfiles_configuration";

  postInstall =
    ''
      # This no longer matches the expected blkid invocation,
      # and can probably be removed.
      substituteInPlace $out/lib/udev/rules.d/13-dm-disk.rules \
        --replace $out/sbin/blkid ${utillinux}/sbin/blkid

      # Systemd stuff
      mkdir -p $out/etc/systemd/system $out/lib/systemd/system-generators
      cp scripts/blk_availability_systemd_red_hat.service $out/etc/systemd/system
      cp scripts/lvm2_activation_generator_systemd_red_hat $out/lib/systemd/system-generators

      # Look for systemd-run relative
      substituteInPlace $out/lib/udev/rules.d/69-dm-lvm-metad.rules \
        --replace $out/bin/systemd-run systemd-run
    '';

  meta = with stdenv.lib; {
    homepage = http://sourceware.org/lvm2/;
    description = "Tools to support Logical Volume Management (LVM) on Linux";
    platforms = platforms.linux;
    license = with licenses; [ gpl2 bsd2 lgpl21 ];
    maintainers = with maintainers; [raskin];
    inherit version;
    downloadPage = "ftp://sources.redhat.com/pub/lvm2/";
  };
}
