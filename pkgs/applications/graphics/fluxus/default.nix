{ stdenv
, fetchFromGitLab
, alsaLib
, bzip2
, fftw
, freeglut
, freetype
, glew
, libjack2
, libGL
, libGLU
, libjpeg
, liblo
, libpng
, libsndfile
, libtiff
, ode
, openal
, openssl
, racket
, scons
, zlib
}:
let
  libs = [
    alsaLib
    bzip2
    fftw
    freeglut
    freetype
    glew
    libjack2
    libGL
    libGLU
    libjpeg
    liblo
    libpng
    libsndfile
    libtiff
    ode
    openal
    openssl
    zlib
  ];
  libPath = stdenv.lib.makeLibraryPath libs;
in
stdenv.mkDerivation rec {
  pname = "fluxus";
  version = "0.19";
  src = fetchFromGitLab {
    owner = "nebogeo";
    repo = "fluxus";
    rev = "ba9aee218dd4a9cfab914ad78bdb6d59e9a37400";
    hash = "sha256:0mwghpgq4n1khwlmgscirhmcdhi6x00c08q4idi2zcqz961bbs28";
  };

  nativeBuildInputs = [ scons ];
  buildInputs = [
    alsaLib
    fftw
    freeglut
    freetype
    glew
    libjack2
    libjpeg
    liblo
    libsndfile
    libtiff
    ode
    openal
    openssl
    racket
  ];
  patches = [ ./fix-build.patch ];

  sconsFlags = [
    "Prefix=${placeholder "out"}"
    "RacketPrefix=${racket}"
    "RacketInclude=${racket}/include/racket"
    "RacketLib=${racket}/lib/racket"
    "LIBPATH=${libPath}"
    "DESTDIR=/"
  ];

  meta = with stdenv.lib; {
    description = "Livecoding environment for 3D graphics, sound, and games";
    license = licenses.gpl2;
    homepage = http://www.pawfal.org/fluxus/;
    maintainers = [ maintainers.brainrape ];
  };
}
