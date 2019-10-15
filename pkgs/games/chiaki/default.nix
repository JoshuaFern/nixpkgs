{ lib, mkDerivation, fetchFromGitHub
, cmake, ffmpeg, libopus, qtbase, qtmultimedia, qtsvg, pkgconfig, protobuf
, python3Packages, SDL2 }:

mkDerivation rec {
  pname = "chiaki";
  version = "1.0.4";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "thestr4ng3r";
    repo = "chiaki";
    fetchSubmodules = true;
    sha256 = "0l4hxrzcvpqlqnjnk6bvv8xqrxv6q6p0x02v6mwqkf231iin51w8";
  };

  nativeBuildInputs = [
    cmake pkgconfig protobuf python3Packages.python python3Packages.protobuf
  ];
  buildInputs = [ ffmpeg libopus qtbase qtmultimedia qtsvg protobuf SDL2 ];

  doCheck = true;

  meta = with lib; {
    homepage = "https://github.com/thestr4ng3r/chiaki";
    description = "Free and Open Source PS4 Remote Play Client";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ delroth ];
    platforms = platforms.all;
  };
}
