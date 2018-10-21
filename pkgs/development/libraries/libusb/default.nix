{stdenv, fetchurl, pkgconfig, libusb1}:

stdenv.mkDerivation rec {
  name = "libusb-compat-${version}";
  version = "0.1.7";

  outputs = [ "out" "dev" ]; # get rid of propagating systemd closure
  outputBin = "dev";

  nativeBuildInputs = [ pkgconfig ];
  propagatedBuildInputs = [ libusb1 ];

  src = fetchurl {
    url = "https://github.com/libusb/libusb-compat-0.1/releases/download/v${version}/${name}.tar.bz2";
    sha256 = "1mk48z0qq8lxqdk244cd5fa23fp0aplkka93g3247zl4n3azhnc2";
  };

  patches = stdenv.lib.optional stdenv.hostPlatform.isMusl ./fix-headers.patch;

  meta = with stdenv.lib; {
    homepage = "https://libusb.info/";
    repositories.git = "https://github.com/libusb/libusb-compat-0.1";
    description = "cross-platform user-mode USB device library";
    longDescription = ''
      libusb is a cross-platform user-mode library that provides access to USB devices.
      The current API is of 1.0 version (libusb-1.0 API), this library is a wrapper exposing the legacy API.
    '';
    license = licenses.lgpl2Plus;
    platforms = platforms.unix;
  };
}
