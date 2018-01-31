{ stdenv, lib, buildGoPackage, fetchFromGitHub, gpgme, libgpgerror, devicemapper, btrfs-progs, pkgconfig, ostree, runCommand }:

with stdenv.lib;

let
  version = "0.1.27";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "projectatomic";
    repo = "skopeo";
    sha256 = "1xwwzxjczz8qdk1rf0h78qd3vk9mxxb8yi6f8kfqvcdcsvkajd5g";
  };

  defaultPolicyFile = runCommand "skopeo-default-policy.json" {} "cp ${src}/default-policy.json $out";

in
buildGoPackage rec {
  name = "skopeo-${version}";
  inherit src;

  goPackagePath = "github.com/projectatomic/skopeo";
  excludedPackages = "integration";

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ gpgme libgpgerror devicemapper btrfs-progs ostree ];

  buildFlagsArray = "-ldflags= -X github.com/projectatomic/skopeo/vendor/github.com/containers/image/signature.systemDefaultPolicyPath=${defaultPolicyFile}";

  preBuild = ''
    export CGO_CFLAGS="-I${getDev gpgme}/include -I${getDev libgpgerror}/include -I${getDev devicemapper}/include -I${getDev btrfs-progs}/include"
    export CGO_LDFLAGS="-L${getLib gpgme}/lib -L${getLib libgpgerror}/lib -L${getLib devicemapper}/lib"
  '';

  meta = {
    description = "A command line utility for various operations on container images and image repositories";
    homepage = https://github.com/projectatomic/skopeo;
    maintainers = with stdenv.lib.maintainers; [ vdemeester ];
    license = stdenv.lib.licenses.asl20;
  };
}
