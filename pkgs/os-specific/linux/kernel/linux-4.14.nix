{ stdenv, buildPackages, fetchurl, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with stdenv.lib;

buildLinux (args // rec {
  version = "4.14.108";

  # modDirVersion needs to be x.y.z, will automatically add .0 if needed

  # branchVersion needs to be x.y
  extraMeta.branch = concatStrings (intersperse "." (take 2 (splitString "." version)));

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v4.x/linux-${version}.tar.xz";
    sha256 = "0m6liqxbyfsy2xx01blsw383zaqpbjc4h7wn9y9i7k96gxl3rqxn";
  };
} // (args.argsOverride or {}))
