{ stdenv, fetchFromGitHub, makeWrapper
, libaio, python, zlib
, withGnuplot ? false, gnuplot ? null }:

stdenv.mkDerivation rec {
  pname = "fio";
  version = "3.18";

  src = fetchFromGitHub {
    owner  = "axboe";
    repo   = pname;
    rev    = "${pname}-${version}";
    sha256 = "0p2w1pyjh7vjxqxibjawi7waqb7n0lwnx21qj0z75g8zhb629l0w";
  };

  buildInputs = [ python zlib ]
    ++ stdenv.lib.optional (!stdenv.isDarwin) libaio;

  nativeBuildInputs = [ makeWrapper ];

  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace Makefile \
      --replace "mandir = /usr/share/man" "mandir = \$(prefix)/man" \
      --replace "sharedir = /usr/share/fio" "sharedir = \$(prefix)/share/fio"
    substituteInPlace tools/plot/fio2gnuplot --replace /usr/share/fio $out/share/fio
  '';

  postInstall = stdenv.lib.optionalString withGnuplot ''
    wrapProgram $out/bin/fio2gnuplot \
      --prefix PATH : ${stdenv.lib.makeBinPath [ gnuplot ]}
  '';

  meta = with stdenv.lib; {
    description = "Flexible IO Tester - an IO benchmark tool";
    homepage = "http://git.kernel.dk/?p=fio.git;a=summary;";
    license = licenses.gpl2;
    platforms = platforms.unix;
  };
}
