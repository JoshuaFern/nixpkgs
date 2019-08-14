{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, glib, libuuid, gobject-introspection, gtk-doc, shared-mime-info, python3, docbook_xsl, docbook_xml_dtd_43 }:

stdenv.mkDerivation rec {
  name = "libxmlb-${version}";
  version = "0.1.11";

  outputs = [ "out" "lib" "dev" "devdoc" ];

  src = fetchFromGitHub {
    owner = "hughsie";
    repo = "libxmlb";
    rev = version;
    sha256 = "1503v76w7543snqyjxykiqa5va62zb0ccn3jlw0gpdx8973v80mr";
  };

  nativeBuildInputs = [ meson ninja python3 pkgconfig gobject-introspection gtk-doc shared-mime-info docbook_xsl docbook_xml_dtd_43 ];

  buildInputs = [ glib libuuid ];

  mesonFlags = [
    "--libexecdir=${placeholder "out"}/libexec"
    "-Dgtkdoc=true"
  ];

  doCheck = true;
  preCheck = ''
    XDG_DATA_DIRS="$XDG_DATA_DIRS:${shared-mime-info}/share"
  '';

  meta = with stdenv.lib; {
    description = "A library to help create and query binary XML blobs";
    homepage = https://github.com/hughsie/libxmlb;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ jtojnar ];
    platforms = platforms.linux;
  };
}
