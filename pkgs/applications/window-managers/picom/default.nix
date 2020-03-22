{ stdenv, lib, fetchFromGitHub, pkgconfig, uthash, asciidoc, docbook_xml_dtd_45
, docbook_xsl, libxslt, libxml2, makeWrapper, meson, ninja
, xorgproto, libxcb ,xcbutilrenderutil, xcbutilimage, pixman, libev
, dbus, libconfig, libdrm, libGL, pcre, libX11
, libXinerama, libXext, xprop, xwininfo }:
stdenv.mkDerivation rec {
  pname = "picom";
  #version = "7.3";
  version = "unstable-2020-03-22";

  COMPTON_VERSION = "v${version}";

  src = fetchFromGitHub {
    owner  = "yshui";
    repo   = pname;
    #rev    = COMPTON_VERSION;
    rev = "97db599fd8726235beae62391724ad26aa0a0856";
    sha256 = "10wdk4zxk4kb3ibpwapky99zl8z7k5w0b0gyygn2qvd4d67k7hvq";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson ninja
    pkgconfig
    uthash
    asciidoc
    docbook_xml_dtd_45
    docbook_xsl
    makeWrapper
  ];

  buildInputs = [
    dbus libX11 libXext
    xorgproto
    libXinerama libdrm pcre libxml2 libxslt libconfig libGL
    libxcb xcbutilrenderutil xcbutilimage
    pixman libev
    # TODO: upstream, check if still needed
    uthash
  ];

  NIX_CFLAGS_COMPILE = [
    "-fno-strict-aliasing"
    # These control some verbose debugging info
    # useful should anything go wrong but not suitable
    # for regular use.
    #"-DDEBUG_RESTACK=1"
    #"-DDEBUG_EVENTS=1"
  ];

  # This doesn't help anymore, IIRC, TODO: check and report to nixpkgs master
  ##preBuild = ''
  ##  git() { echo "v${version}"; }
  ##  export -f git
  ##'';

  doCheck = true;

  mesonFlags = [
    "-Dwith_docs=true"
    "-Dunittest=true"
    # Optional, I prefer to leave it on for sanity's sake
#    "-Dsanitize=true"
  ];

  installFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram $out/bin/picom-trans \
      --prefix PATH : ${lib.makeBinPath [ xprop xwininfo ]}
    # just replace compton-trans symlink instead of wrapping it too
    ln -srfv $out/bin/{picom,compton}-trans
  '';

  meta = with lib; {
    description = "A fork of XCompMgr, a sample compositing manager for X servers";
    longDescription = ''
      A fork of XCompMgr, which is a sample compositing manager for X
      servers supporting the XFIXES, DAMAGE, RENDER, and COMPOSITE
      extensions. It enables basic eye-candy effects. This fork adds
      additional features, such as additional effects, and a fork at a
      well-defined and proper place.
    '';
    license = licenses.mit;
    homepage = "https://github.com/yshui/picom";
    maintainers = with maintainers; [ ertes enzime twey ];
    platforms = platforms.linux;
  };
}
