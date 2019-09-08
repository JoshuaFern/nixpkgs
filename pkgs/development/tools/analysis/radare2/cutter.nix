{ stdenv, fetchFromGitHub
# nativeBuildInputs
, cmake, qmake, pkgconfig
# Qt
, qtbase, qtsvg
, wrapQtAppsHook
# buildInputs
, r2-for-cutter
, python3
# optional
, graphviz
, syntax-highlighting
}:

stdenv.mkDerivation rec {
  pname = "radare2-cutter";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "radareorg";
    repo = "cutter";
    rev = "v${version}";
    sha256 = "1ln55ssrasbaam267lwc2vxnm8j0c2x35qsda44xi2p8hqxslf8k";
  };

  postUnpack = "export sourceRoot=$sourceRoot/src";

  # Remove this "very helpful" helper file intended for discovering r2,
  # as it's a doozy of harddcoded paths and unexpected behavior.
  # Happily Nix has everything all set so we don't need it,
  # other than as basis for the qmakeFlags set below.
  postPatch = ''
    substituteInPlace Cutter.pro \
      --replace "include(lib_radare2.pri)" ""
  '';

  nativeBuildInputs = [ cmake qmake pkgconfig ];
  buildInputs = [ qtbase qtsvg r2-for-cutter python3 graphviz syntax-highlighting wrapQtAppsHook ];

  #qmakeFlags = [
  #  "CONFIG+=link_pkgconfig"
  #  "PKGCONFIG+=r_core"
  #  "CUTTER_ENABLE_GRAPHVIZ=true"
  #  "CUTTER_ENABLE_KSYNTAXHIGHLIGHTING=true"
  #  # Leaving this enabled doesn't break build but generates errors
  #  # at runtime (to console) about being unable to load needed bits.
  #  # Disable until can be looked at.
  #  "CUTTER_ENABLE_JUPYTER=false"
  #];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A Qt and C++ GUI for radare2 reverse engineering framework";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ mic92 dtzWill ];
  };
}
