{ stdenv, fetchFromGitHub, meson, ninja, gettext, pkgconfig, python3
, wrapGAppsHook, gobject-introspection
, gjs, gtk3, gsettings-desktop-schemas, webkitgtk, glib
, desktop-file-utils
, cairo, libgee, pantheon /* granite */, libxml2, libarchive
/*, hyphen */
, dict }:

stdenv.mkDerivation rec {
  pname = "foliate";
  version = "1.5.1";

  # Fetch this from gnome mirror if/when available there instead!
  src = fetchFromGitHub {
    owner = "johnfactotum";
    repo = pname;
    rev = version;
    sha256 = "10zxwj56psygkbc4b5kw6q5nz2acifh3fdiv3b69v67wgjppfgzx";
  };

  nativeBuildInputs = [
    meson ninja
    pkgconfig
    gettext
    python3
    desktop-file-utils
    wrapGAppsHook
  ];
  buildInputs = [
    glib
    gtk3
    gjs
    webkitgtk
    gsettings-desktop-schemas
    gobject-introspection
    cairo
    libgee
    pantheon.granite
    libxml2
    libarchive
    # TODO: Add once packaged, unclear how language packages best handled
    # hyphen
    dict # dictd for offline dictionary support
  ];

  doCheck = true;

  postPatch = ''
    chmod +x build-aux/meson/postinstall.py
    patchShebangs build-aux/meson/postinstall.py
  '';

  # Kludge so gjs can find resources by using the unwrapped name
  # Improvements/alternatives welcome, but this seems to work for now :/.
  # See: https://github.com/NixOS/nixpkgs/issues/31168#issuecomment-341793501
  postInstall = ''
    sed -ie "2iimports.package._findEffectiveEntryPointName = () => 'com.github.johnfactotum.Foliate'\n" \
      $out/bin/com.github.johnfactotum.Foliate

  '';
}
