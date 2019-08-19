{ stdenv, fetchurl, python, perl, intltool, flex, texinfo, libiconv, libintl }:

stdenv.mkDerivation rec {
  pname = "recode";
  version = "3.7.2";

  # Use official tarball, avoid need to bootstrap/generate build system
  src = fetchurl {
    url = "https://github.com/rrthomas/${pname}/releases/download/v${version}/${pname}-${version}.tar.gz";
    sha256 = "1k1rjbcna6xn0nq8na9wi1d54q5671gc4s1ibkgayx95l47rsb4b";
  };

  nativeBuildInputs = [ python python.pkgs.cython perl intltool flex texinfo libiconv ];
  buildInputs = [ libintl ];

  doCheck = true;

  meta = {
    homepage = https://github.com/rrthomas/recode;
    description = "Converts files between various character sets and usages";
    platforms = stdenv.lib.platforms.unix;
    license = stdenv.lib.licenses.gpl2Plus;
    maintainers = with stdenv.lib.maintainers; [ jcumming ];
  };
}
