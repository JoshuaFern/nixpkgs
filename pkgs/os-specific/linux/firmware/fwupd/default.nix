{ stdenv, fetchurl, fetchFromGitHub, fetchpatch, gtk-doc, pkgconfig, gobjectIntrospection, intltool
, libgudev, polkit, libxmlb, gusb, sqlite, libarchive, glib-networking
, libsoup, help2man, gpgme, libxslt, elfutils, libsmbios, efivar, glibcLocales
, gnu-efi, libyaml, valgrind, meson, libuuid, colord, docbook_xml_dtd_43, docbook_xsl
, ninja, gcab, gnutls, python3, wrapGAppsHook, json-glib, bash-completion
, shared-mime-info, umockdev, vala, makeFontsConf, freefont_ttf
, cairo, freetype, fontconfig, pango

}:
let
  # Updating? Keep $out/etc synchronized with passthru.filesInstalledToEtc
  #version = "1.2.1";
  version = "2018-11-27";
  python = python3.withPackages (p: with p; [ pygobject3 pycairo pillow ]);
  installedTestsPython = python3.withPackages (p: with p; [ pygobject3 requests ]);

  fontsConf = makeFontsConf {
    fontDirectories = [ freefont_ttf ];
  };
in stdenv.mkDerivation {
  name = "fwupd-${version}";
  src = fetchFromGitHub {
    owner = "hughsie";
    repo = "fwupd";
    rev = "b4fd12a4c6d877820e87598edf5ef5e4867735ba";
    sha256 = "1wlcn78bxamp5dy469fkc4nimcwk0gqaz3a8kjb0dbdbq9g38ka8";
  };

  #src = fetchurl {
  #  url = "https://people.freedesktop.org/~hughsient/releases/fwupd-${version}.tar.xz";
  #  sha256 = "126b3lsh4gkyajsqm2c8l6wqr4dd7m26krz2527khmlps0lxdhg1";
  #};

  outputs = [ "out" "lib" "dev" "devdoc" "man" "installedTests" ];

  nativeBuildInputs = [
    meson ninja gtk-doc pkgconfig gobject-introspection intltool glibcLocales shared-mime-info
    valgrind gcab docbook_xml_dtd_43 docbook_xsl help2man libxslt python wrapGAppsHook vala
  ];
  buildInputs = [
    polkit libxmlb gusb sqlite libarchive libsoup elfutils libsmbios gnu-efi libyaml
    libgudev colord gpgme libuuid gnutls glib-networking efivar json-glib umockdev
    bash-completion cairo freetype fontconfig pango
  ];

  LC_ALL = "en_US.UTF-8"; # For po/make-images

  patches = [
    ./fix-paths.patch
    ./add-option-for-installation-sysconfdir.patch
  ];

  postPatch = ''
    # needs a different set of modules than po/make-images
    escapedInterpreterLine=$(echo "${installedTestsPython}/bin/python3" | sed 's|\\|\\\\|g')
    sed -i -e "1 s|.*|#\!$escapedInterpreterLine|" data/installed-tests/hardware.py

    patchShebangs .
    substituteInPlace data/installed-tests/fwupdmgr.test.in --subst-var-by installedtestsdir "$installedTests/share/installed-tests/fwupd"

    # /etc/daemon.conf
    substituteInPlace meson.build --replace \
      "conf.set_quoted('SYSCONFDIR', sysconfdir)" \
      "conf.set_quoted('SYSCONFDIR', '/etc')"

    substituteInPlace data/installed-tests/meson.build --replace sysconfdir sysconfdir_install
  '';

  # /etc/os-release not available in sandbox
  # doCheck = true;

  preFixup = ''
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${shared-mime-info}/share")
  '';

  mesonFlags = [
    "-Dplugin_dummy=true"
    "-Dudevdir=lib/udev"
    "-Dsystemdunitdir=lib/systemd/system"
    "-Defi-libdir=${gnu-efi}/lib"
    "-Defi-ldsdir=${gnu-efi}/lib"
    "-Defi-includedir=${gnu-efi}/include/efi"
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "-Dsysconfdir_install=${placeholder "out"}/etc"
  ];

  # TODO: We need to be able to override the directory flags from meson setup hook
  # better – declaring them multiple times might become an error.
  preConfigure = ''
    mesonFlagsArray+=("--libexecdir=$out/libexec")
  '';

  postInstall = ''
    moveToOutput share/installed-tests "$installedTests"
    wrapProgram $installedTests/share/installed-tests/fwupd/hardware.py \
      --prefix GI_TYPELIB_PATH : "$out/lib/girepository-1.0:${libsoup}/lib/girepository-1.0"
  '';

  FONTCONFIG_FILE = fontsConf; # Fontconfig error: Cannot load default config file

  # TODO: wrapGAppsHook wraps efi capsule even though it is not elf
  dontWrapGApps = true;
  # so we need to wrap the executables manually
  postFixup = ''
    find -L "$out/bin" "$out/libexec" -type f -executable -print0 \
      | while IFS= read -r -d ''' file; do
      if [[ "''${file}" != *.efi ]]; then
        echo "Wrapping program ''${file}"
        wrapProgram "''${file}" "''${gappsWrapperArgs[@]}"
      fi
    done
  '';

  # /etc/fwupd/uefi.conf is created by the services.hardware.fwupd NixOS module
  passthru = {
    filesInstalledToEtc = [
      "fwupd/remotes.d/fwupd.conf"
      "fwupd/remotes.d/lvfs-testing.conf"
      "fwupd/remotes.d/lvfs.conf"
      "fwupd/remotes.d/vendor.conf"
      "pki/fwupd/GPG-KEY-Hughski-Limited"
      "pki/fwupd/GPG-KEY-Linux-Foundation-Firmware"
      "pki/fwupd/GPG-KEY-Linux-Vendor-Firmware-Service"
      "pki/fwupd/LVFS-CA.pem"
      "pki/fwupd-metadata/GPG-KEY-Linux-Foundation-Metadata"
      "pki/fwupd-metadata/GPG-KEY-Linux-Vendor-Firmware-Service"
      "pki/fwupd-metadata/LVFS-CA.pem"
    ];
  };

  meta = with stdenv.lib; {
    homepage = https://fwupd.org/;
    maintainers = with maintainers; [];
    license = [ licenses.gpl2 ];
    platforms = platforms.linux;
  };
}
