{
  stdenv, fetchurl, lib,
  libxslt, pandoc, asciidoctor, pkgconfig,
  dbus-glib, libcap_ng, libqb, libseccomp, polkit, protobuf, qtbase, qttools, qtsvg,
  audit,
  libgcrypt ? null,
  libsodium ? null
}:

with stdenv.lib;

assert libgcrypt != null -> libsodium == null;

stdenv.mkDerivation rec {
  version = "0.7.5";
  pname = "usbguard";

  repo = "https://github.com/USBGuard/usbguard";

  src = fetchurl {
    url = "${repo}/releases/download/${pname}-${version}/${pname}-${version}.tar.gz";
    sha256 = "0jj56sls13ryfgz6vajq8p4dm3grgb6rf2cmga6sckmzd4chk65b";
  };

  nativeBuildInputs = [
    libxslt
    asciidoctor
    pandoc # for rendering documentation
    pkgconfig
  ];

  buildInputs = [
    dbus-glib
    libcap_ng
    libqb
    libseccomp
    polkit
    protobuf
    audit

    qtbase
    qtsvg
    qttools
  ]
  ++ (lib.optional (libgcrypt != null) libgcrypt)
  ++ (lib.optional (libsodium != null) libsodium);

  configureFlags = [
    "--with-bundled-catch"
    "--with-bundled-pegtl"
    "--with-dbus"
    "--with-gui-qt=qt5"
    "--with-polkit"
  ]
  ++ (lib.optional (libgcrypt != null) "--with-crypto-library=gcrypt")
  ++ (lib.optional (libsodium != null) "--with-crypto-library=sodium");

  enableParallelBuilding = true;

  meta = {
    description = "The USBGuard software framework helps to protect your computer against BadUSB.";
    homepage = "https://usbguard.github.io/";
    license = licenses.gpl2;
    maintainers = [ maintainers.tnias ];
  };
}
