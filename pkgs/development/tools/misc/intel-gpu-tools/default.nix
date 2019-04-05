{ stdenv, fetchurl, fetchgit, pkgconfig, libdrm, libpciaccess, cairo, pixman, udev, xorgproto
, libX11, libXext, libXv, libXrandr, glib, bison, libunwind, python3, kmod
, procps, utilmacros, gtk-doc, openssl, peg, meson, ninja, elfutils, flex }:

stdenv.mkDerivation rec {
  name = "intel-gpu-tools-${version}";
  version = "1.23-git";

  src = fetchgit {
    url = https://gitlab.freedesktop.org/drm/igt-gpu-tools;
    rev = "08cf63a8fac11e3594b57580331fb319241a0d69";
    sha256 = "1b7xj7xxvchbb8k93jc9pb0yzydxmpww28f9526v33n55fdz0fyp";
  };
  #src = fetchurl {
  #  url = "https://xorg.freedesktop.org/archive/individual/app/igt-gpu-tools-${version}.tar.xz";
  #  sha256 = "1l4s95m013p2wvddwr4cjqyvsgmc88zxx2887p1fbb1va5n0hjsd";
  #};

  nativeBuildInputs = [ pkgconfig utilmacros meson ninja flex ];
  buildInputs = [ libdrm libpciaccess cairo pixman xorgproto udev libX11 kmod
    libXext libXv libXrandr glib bison libunwind python3 procps
    gtk-doc openssl peg elfutils ];

  #preConfigure = ''
  #  ./autogen.sh
  #'';

  mesonFlags = [ "-Dbuild_docs=false" ];

  postPatch = ''
    patchShebangs tests

    patchShebangs debugger/system_routine/pre_cpp.py
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = https://01.org/linuxgraphics/;
    description = "Tools for development and testing of the Intel DRM driver";
    license = licenses.mit;
    platforms = [ "x86_64-linux" "i686-linux" ];
    maintainers = with maintainers; [ pSub ];
  };
}
