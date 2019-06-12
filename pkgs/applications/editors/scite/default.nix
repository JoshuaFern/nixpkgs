{ stdenv, fetchurl, pkgconfig, lua, glib, gtk3, wrapGAppsHook }:

stdenv.mkDerivation rec {
  pname = "scite";
  version = "4.1.6";

  src = fetchurl {
    url = "https://www.scintilla.org/scite${builtins.replaceStrings ["."][""] version}.tgz";
    sha256 = "0k10qjil101mxlmd39sdz1n9yaif0x5q6vl03is48jrh4lvvlfyy";
  };

  nativeBuildInputs = [ pkgconfig wrapGAppsHook ];
  buildInputs = [ glib gtk3 lua ];

  sourceRoot = "scite/gtk";

  makeFlags = [ "gnomeprefix=${placeholder "out"}" "prefix=${placeholder "out"}" "DESTDIR=" "GTK3=1" ];
  buildPhase = ''
    make -C ../../scintilla/gtk $makeFlags -j
    make $makeFlags -j
  '';

  postInstall = "ln -sr $out/bin/SciTE $out/bin/scite";

  meta = with stdenv.lib; {
    homepage = https://www.scintilla.org/SciTE.html;
    description = "SCIntilla based Text Editor";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ maintainers.rszibele ];
  };
}
