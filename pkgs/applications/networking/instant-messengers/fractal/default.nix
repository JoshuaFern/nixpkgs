{ stdenv, fetchurl, fetchFromGitLab, meson, ninja, gettext, cargo, rustc, python3, rustPlatform, pkgconfig, gtksourceview
, hicolor-icon-theme, glib, libhandy, gtk3, libsecret, gspell, dbus, openssl, sqlite, gst_all_1, wrapGAppsHook }:

rustPlatform.buildRustPackage rec {
  version = "4.0.0.0.1"; # not really
  name = "fractal-${version}";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "fractal";
    #rev = version;
    rev = "1327faef176d92691876d31d3d386f7adf4df969";
    sha256 = "1a2hwskbk605nq0ik4cgv80r6fdq7imjml59czq651wahq7m5f8f";
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

