{ fetchurl, stdenv }:

stdenv.mkDerivation rec {
  pname = "gengetopt";
  version = "2.23";

  src = fetchurl {
    url = "mirror://gnu/${pname}/${pname}-${version}.tar.xz";
    sha256 = "1b44fn0apsgawyqa4alx2qj5hls334mhbszxsy6rfr0q074swhdr";
  };

  doCheck = true;

  #Fix, see #28255
  postPatch = ''
    substituteInPlace configure --replace \
      'set -o posix' \
      'set +o posix'
  '';

  meta = {
    description = "Command-line option parser generator";

    longDescription =
      '' GNU Gengetopt program generates a C function that uses getopt_long
         function to parse the command line options, to validate them and
         fills a struct
      '';

    homepage = https://www.gnu.org/software/gengetopt/;

    license = stdenv.lib.licenses.gpl3Plus;

    maintainers = [ ];
    platforms = stdenv.lib.platforms.all;
  };
}
