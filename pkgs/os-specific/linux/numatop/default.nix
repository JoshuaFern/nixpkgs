{ stdenv, fetchurl, pkgconfig, numactl, ncurses, check, linuxHeaders }:

stdenv.mkDerivation rec {
  pname = "numatop";
  version = "2.1";
  src = fetchurl {
    url = "https://github.com/intel/${pname}/releases/download/v${version}/${pname}-v${version}.tar.xz";
    sha256 = "1s7psq1xyswj0lpx10zg5lnppav2xy9safkfx3rssrs9c2fp5d76";
  };

  postPatch = ''
    # rm common/include/os/linux/perf_event.h
    substituteInPlace common/include/os/pfwrapper.h --replace '"linux/perf_event.h"' '<linux/perf_event.h>'

    sed -i -e '1i#include<unistd.h>\n#include <sys/syscall.h>' common/include/os/pfwrapper.h
  '';

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ numactl ncurses linuxHeaders ];
  checkInputs = [ check ];

  doCheck  = true;

  meta = with stdenv.lib; {
    description = "observation tool for runtime memory locality characterization and analysis of processes and threads running on a NUMA system";
    homepage = https://01.org/numatop;
    license = licenses.bsd3;
    maintainers = with maintainers; [ dtzWill ];
    platforms = stdenv.lib.platforms.all;
  };
}
