{ fetchurl }:

rec {
  major = "6";
  minor = "2";
  patch = "5";
  tweak = "2";

  subdir = "${major}.${minor}.${patch}";

  version = "${subdir}${if tweak == "" then "" else "."}${tweak}";

  src = fetchurl {
    url = "https://download.documentfoundation.org/libreoffice/src/${subdir}/libreoffice-${version}.tar.xz";
    sha256 = "13immid07w22377wxf3p6hjr3a0n7phszfn62mad7qkyn7lh170f";
  };
}
