{ stdenv, fetchurl, substituteAll, intltool, pkgconfig, dbus, dbus-glib
, gnome3, systemd, libuuid, polkit, gnutls, ppp, dhcp, iptables, python3, vala
, libgcrypt, dnsmasq, bluez5, readline, libselinux, audit
, gobject-introspection, modemmanager, openresolv, libndp, newt, libsoup
, ethtool, gnused, iputils, kmod, jansson, gtk-doc, libxslt
, docbook_xsl, docbook_xml_dtd_412, docbook_xml_dtd_42, docbook_xml_dtd_43
, fetchFromGitHub
, mobile-broadband-provider-info
, openconnect, curl, meson, ninja, libpsl, libredirect }:

let
  pname = "NetworkManager";
  pythonForDocs = python3.withPackages (pkgs: with pkgs; [ pygobject3 ]);
in stdenv.mkDerivation rec {
  inherit pname;
#  version = "1.19.5-dev"; # 2019-07-22
  version = "unstable-2019-10-27";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
  #  rev = "refs/tags/${version}";
    rev = "074e5503d7ff7af853785f4cbb64fbfc43d1ef6a";
    sha256 = "1g2sc16mf4hjxhgd07g3h827nc39jmj5l33dyd4dwa25xkgnpk44";
  };
  #src = fetchurl {
  #  url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
  #  sha256 = "0wxx1h8k7ya0ygj046ddwwdr05wc2rkj6jx8j11vnswafrq4l6ri";
  #};

  outputs = [ "out" "dev" "devdoc" "man" "doc" ];

  # Right now we hardcode quite a few paths at build time. Probably we should
  # patch networkmanager to allow passing these path in config file. This will
  # remove unneeded build-time dependencies.
  mesonFlags = [
    "-Ddhclient=${dhcp}/bin/dhclient"
    "-Ddnsmasq=${dnsmasq}/bin/dnsmasq"
    # Upstream prefers dhclient, so don't add dhcpcd to the closure
    "-Ddhcpcd=no"
    "-Ddhcpcanon=no"
    "-Dpppd=${ppp}/bin/pppd"
    "-Diptables=${iptables}/bin/iptables"
    # to enable link-local connections
    "-Dudev_dir=${placeholder "out"}/lib/udev"
    "-Dresolvconf=${openresolv}/bin/resolvconf"
    "-Ddbus_conf_dir=${placeholder "out"}/etc/dbus-1/system.d"
    "-Dsystemdsystemunitdir=${placeholder "out"}/etc/systemd/system"
    "-Dkernel_firmware_dir=/run/current-system/firmware"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "-Dcrypto=gnutls"
    "-Dsession_tracking=systemd"
    "-Dmodem_manager=true"
    "-Dnmtui=true"
    "-Ddocs=true"
    "-Dtests=no"
    "-Dqt=false"
    # Allow using iwd when configured to do so
    "-Diwd=true"
    ## #"-Dpolkit_agent=true"
    "-Dpolkit=true"
    ## "-Dconfig_dns_rc_manager_default=resolvconf"
    "-Debpf=true"
    "-Dlibaudit=yes-disabled-by-default"
    ## "-Dsession_tracking_consolekit=false"
  ];

  patches = [
    (substituteAll {
      src = ./fix-paths.patch;
      inherit iputils kmod openconnect ethtool gnused systemd;
      inherit (stdenv) shell;
    })

    # Meson does not support using different directories during build and
    # for installation like Autotools did with flags passed to make install.
    ./fix-install-paths.patch

    ./fix-build-with-tests-disabled.patch

    ./iwd-new-root-path.patch
    ./iwd-new-root-path-part2.patch
    # ./iwd-sae.patch
  ];

  buildInputs = [
    systemd libselinux audit libpsl libuuid polkit ppp libndp curl
    bluez5 dnsmasq gobject-introspection modemmanager readline newt libsoup jansson
    mobile-broadband-provider-info
  ];

  propagatedBuildInputs = [ dbus-glib gnutls libgcrypt ];

  nativeBuildInputs = [
    meson ninja intltool pkgconfig
    vala gobject-introspection
    dbus-glib # for dbus-binding-tool
    # Docs
    gtk-doc libxslt docbook_xsl docbook_xml_dtd_412 docbook_xml_dtd_42 docbook_xml_dtd_43 pythonForDocs
  ];

  doCheck = false; # requires /sys, the net


  postPatch = ''
    patchShebangs ./tools
    patchShebangs libnm/generate-setting-docs.py

    substituteInPlace libnm/meson.build \
      --replace 'python.path()' \
                "'${pythonForDocs.interpreter}'"
  '';

  preBuild = ''
    # Our gobject-introspection patches make the shared library paths absolute
    # in the GIR files. When building docs, the library is not yet installed,
    # though, so we need to replace the absolute path with a local one during build.
    # We are using a symlink that will be overridden during installation.
    mkdir -p ${placeholder "out"}/lib
    ln -s $PWD/libnm/libnm.so.0 ${placeholder "out"}/lib/libnm.so.0
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "networkmanager";
    };
  };

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Projects/NetworkManager;
    description = "Network configuration and management tool";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ phreedom domenkozar obadz ];
    platforms = platforms.linux;
  };
}
