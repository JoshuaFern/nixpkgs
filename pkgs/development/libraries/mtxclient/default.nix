{ stdenv, fetchFromGitHub, fetchpatch, cmake, pkgconfig
, boost, openssl, zlib, libsodium, olm, gtest, spdlog, nlohmann_json }:

stdenv.mkDerivation rec {
  name = "mtxclient-${version}";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "Nheko-Reborn";
    repo = "mtxclient";
    rev = "v${version}";
    sha256 = "0pycznrvj57ff6gbwfn1xj943d2dr4vadl79hii1z16gn0nzxpmj";
  };

  cmakeFlags = [
    "-DBUILD_LIB_TESTS=OFF" "-DBUILD_LIB_EXAMPLES=OFF"
  ];

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [ boost openssl nlohmann_json zlib libsodium olm ];

  meta = with stdenv.lib; {
    description = "Client API library for Matrix, built on top of Boost.Asio";
    homepage = https://github.com/mujx/mtxclient;
    license = licenses.mit;
    maintainers = with maintainers; [ fpletz ];
    platforms = platforms.unix;
  };
}
