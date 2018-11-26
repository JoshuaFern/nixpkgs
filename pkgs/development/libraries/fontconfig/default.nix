{ stdenv, substituteAll, fetchurl, fetchgit
, pkgconfig, freetype, expat, libuuid, libxslt, gperf, dejavu_fonts
}:

/** Font configuration scheme
 - ./config-compat.patch makes fontconfig try the following root configs, in order:
    $FONTCONFIG_FILE, /etc/fonts/${configVersion}/fonts.conf, /etc/fonts/fonts.conf
    This is done not to override config of pre-2.11 versions (which just blow up)
    and still use *global* font configuration at both NixOS or non-NixOS.
 - NixOS creates /etc/fonts/${configVersion}/fonts.conf link to $out/etc/fonts/fonts.conf,
    and other modifications should go to /etc/fonts/${configVersion}/conf.d
 - See ./make-fonts-conf.xsl for config details.

*/

let
  configVersion = "2.11"; # bump whenever fontconfig breaks compatibility with older configurations
in
stdenv.mkDerivation rec {
  name = "fontconfig-${version}";
  version = "2018-11-15"; # 2.13.1+
  src = fetchgit {
    url = https://gitlab.freedesktop.org/fontconfig/fontconfig;
    rev = "2bd559f75d76b514f789e32c5cc9643fd7c1e9a2";
    sha256 = "187vmsl03p7rgyn3ra4wmdgdhg6xxfcia6f0m05q6n73ahnp5lgi";
  };
  #version = "2.13.1";

  #src = fetchurl {
  #  url = "http://fontconfig.org/release/${name}.tar.bz2";
  #  sha256 = "0hb700a68kk0ip51wdlnjjc682kvlrmb6q920mzajykdk0mdsmgn";
  #};

  patches = [
    (substituteAll {
      src = ./config-compat.patch;
      inherit configVersion;
    })
  ];

  outputs = [ "bin" "dev" "lib" "out" ]; # $out contains all the config

  propagatedBuildInputs = [ freetype ];
  nativeBuildInputs = [ pkgconfig gperf libxslt ];
  buildInputs = [ expat libuuid ];

  configureFlags = [
    "--with-arch=${stdenv.hostPlatform.parsed.cpu.name}"
    "--with-cache-dir=/var/cache/fontconfig" # otherwise the fallback is in $out/
    "--disable-docs"
    # just <1MB; this is what you get when loading config fails for some reason
    "--with-default-fonts=${dejavu_fonts.minimal}"
  ] ++ stdenv.lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "--with-arch=${stdenv.hostPlatform.parsed.cpu.name}"
  ];

  enableParallelBuilding = true;

  doCheck = true;

  # Don't try to write to /var/cache/fontconfig at install time.
  installFlags = "fc_cachedir=$(TMPDIR)/dummy RUN_FC_CACHE_TEST=false";

  postInstall = ''
    cd "$out/etc/fonts"
    xsltproc --stringparam fontDirectories "${dejavu_fonts.minimal}" \
      --stringparam fontconfigConfigVersion "${configVersion}" \
      --path $out/share/xml/fontconfig \
      ${./make-fonts-conf.xsl} $out/etc/fonts/fonts.conf \
      > fonts.conf.tmp
    mv fonts.conf.tmp $out/etc/fonts/fonts.conf
  '';

  passthru = {
    inherit configVersion;
  };

  meta = with stdenv.lib; {
    description = "A library for font customization and configuration";
    homepage = http://fontconfig.org/;
    license = licenses.bsd2; # custom but very bsd-like
    platforms = platforms.all;
    maintainers = [ maintainers.vcunat ];
  };
}
