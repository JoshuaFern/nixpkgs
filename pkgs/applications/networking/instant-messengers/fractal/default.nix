{ stdenv, fetchurl, fetchFromGitLab, meson, ninja, gettext, cargo, rustc, python3, rustPlatform, pkgconfig, gtksourceview
, hicolor-icon-theme, glib, libhandy, gtk3, libsecret, gspell, dbus, openssl, sqlite, gst_all_1, wrapGAppsHook }:

rustPlatform.buildRustPackage rec {
  version = "4.0.0"; # not really
  name = "fractal-${version}";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "fractal";
    #rev = version;
    rev = "42e1d50fb1de2b1ecbffa36dc3259a44270a1641";
    sha256 = "13744vbnc2kk41vj77im9xq8ajisk1ikkmbybg3yyplwp4gs79l9";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig gettext cargo rustc python3 wrapGAppsHook
  ];
  buildInputs = [
    glib gtk3 libhandy dbus gspell openssl sqlite
    gtksourceview hicolor-icon-theme
  ] ++ builtins.attrValues { inherit (gst_all_1) gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav gst-editing-services; };

  postPatch = ''
    patchShebangs scripts/meson_post_install.py

    substituteInPlace scripts/test.sh --replace /usr/bin/sh '/usr/bin/env sh'
    chmod +x scripts/test.sh
    patchShebangs scripts/test.sh
    substituteInPlace scripts/test.sh --replace 'cargo test -j1' 'cargo test'

    substituteInPlace meson.build \
      --replace "name_suffix = '" "name_suffix = ' (git)" \
      --replace "version_suffix = '" "version_suffix = '-${builtins.substring 0 8 src.rev}"
  '';

  # Don't use buildRustPackage phases, only use it for rust deps setup
  configurePhase = null;
  buildPhase = null;
  checkPhase = null;
  installPhase = null;

  cargoSha256 = "15v4nynfjp6lpa9vhsrb55ywr6j5ibrambmqr5qlmwbmn4i3861p";

  meta = with stdenv.lib; {
    description = "Matrix group messaging app";
    homepage = https://gitlab.gnome.org/GNOME/fractal;
    license = licenses.gpl3;
    maintainers = with maintainers; [ dtzWill ];
  };
}

