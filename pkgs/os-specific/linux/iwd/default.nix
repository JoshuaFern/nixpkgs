{ stdenv, fetchgit, autoreconfHook, pkgconfig, ell, coreutils, readline, python3Packages }:

# TODO: install the 'ios_convert.py' script added in d8dac9a330be3514a0ee8437ca020dee968a05ca
# (and any req'd dependencies/wrapping, not sure)
stdenv.mkDerivation rec {
  pname = "iwd";

#  version = "0.19";
  version = "2019-08-19";

  src = fetchgit {
    url = https://git.kernel.org/pub/scm/network/wireless/iwd.git;
    # rev = version;
    rev = "610ef41578c1000df77d52d2cb8cb140a31550a7";
    sha256 = "1v71hqvw8f79zi7rjvjybin3zf149kg1nrvzgnjh6izfw5cmv9p5";
  };

  patches = [ ./revert-create-dirs-on-install.patch ];

  nativeBuildInputs = [
    autoreconfHook
    pkgconfig
    python3Packages.wrapPython
  ];

  buildInputs = [
    ell
    readline
    python3Packages.python
  ];

  pythonPath = with python3Packages; [
    dbus-python
    pygobject3
  ];

  configureFlags = [
    "--with-dbus-datadir=${placeholder "out"}/etc/"
    "--with-dbus-busdir=${placeholder "out"}/share/dbus-1/system-services/"
    "--with-systemd-unitdir=${placeholder "out"}/lib/systemd/system/"
    "--with-systemd-modloaddir=${placeholder "out"}/etc/modules-load.d/" # maybe
    "--localstatedir=/var/"
    "--enable-wired"
    "--enable-external-ell"
  ];

  postUnpack = ''
    patchShebangs .
  '';

  postInstall = ''
    cp -a test/* $out/bin/
    mkdir -p $out/share
    cp -a doc $out/share/
    cp -a README AUTHORS TODO $out/share/doc/
  '';

  preFixup = ''
    wrapPythonPrograms
  '';

  postFixup = ''
    substituteInPlace $out/share/dbus-1/system-services/net.connman.ead.service \
                      --replace /bin/false ${coreutils}/bin/false
    substituteInPlace $out/share/dbus-1/system-services/net.connman.iwd.service \
                      --replace /bin/false ${coreutils}/bin/false
  '';

  meta = with stdenv.lib; {
    homepage = https://git.kernel.org/pub/scm/network/wireless/iwd.git;
    description = "Wireless daemon for Linux";
    license = licenses.lgpl21;
    platforms = platforms.linux;
    maintainers = [ maintainers.mic92 ];
  };
}
