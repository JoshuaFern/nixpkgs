{stdenv, fetchFromGitHub
, buildPackages
, callPackage
, pkgconfig
, libusb, readline, libewf, perl, zlib, openssl, capstone
, libuv, file, libzip, xxHash
, gtk2 ? null, vte ? null, gtkdialog ? null
, python3 ? null
, ruby ? null
, lua ? null
, useX11 ? false
, rubyBindings ? false
, pythonBindings ? false
, luaBindings ? false
}:

assert useX11 -> (gtk2 != null && vte != null && gtkdialog != null);
assert rubyBindings -> ruby != null;
assert pythonBindings -> python3 != null;


let
  inherit (stdenv.lib) optional;

  generic = {
    version_commit,
    gittap,
    gittip,
    rev,
    version,
    sha256,
    cs_ver,
    cs_sha256
  }:
    stdenv.mkDerivation rec {
      name = "radare2-${version}";

      src = fetchFromGitHub {
        owner = "radare";
        repo = "radare2";
        inherit rev sha256;
      };

      postInstall = ''
        install -D -m755 $src/binr/r2pm/r2pm $out/bin/r2pm
      '';

      WITHOUT_PULL="1";
      makeFlags = [
        "GITTAP=${gittap}"
        "GITTIP=${gittip}"
        "RANLIB=${stdenv.cc.bintools.bintools}/bin/${stdenv.cc.bintools.targetPrefix}ranlib"
      ];
      configureFlags = [
        "--with-sysmagic"
        "--with-syszip"
        "--with-sysxxhash"
        "--with-syscapstone"
        "--with-openssl"
      ];

      enableParallelBuilding = true;
      depsBuildBuild = [ buildPackages.stdenv.cc ];

      nativeBuildInputs = [ pkgconfig ];
      buildInputs = [ file readline libusb libewf perl zlib openssl libuv ]
        ++ optional useX11 [ gtkdialog vte gtk2 ]
        ++ optional rubyBindings [ ruby ]
        ++ optional pythonBindings [ python3 ]
        ++ optional luaBindings [ lua ];

      propagatedBuildInputs = [
        # radare2 exposes r_lib which depends on these libraries
        file # for its list of magic numbers (`libmagic`)
        libzip
        xxHash
        capstone
      ];

      meta = {
        description = "unix-like reverse engineering framework and commandline tools";
        homepage = http://radare.org/;
        license = stdenv.lib.licenses.gpl2Plus;
        maintainers = with stdenv.lib.maintainers; [ raskin makefu mic92 ];
        platforms = with stdenv.lib.platforms; linux;
        inherit version;
      };
  };
in {
  #<generated>
  # DO NOT EDIT! Automatically generated by ./update.py
  radare2 = generic {
    version_commit = "21830";
    gittap = "3.5.1";
    gittip = "4ec482ba2d4f554beeafb3aa47758e970bcab937";
    rev = "3.5.1";
    version = "3.5.1";
    sha256 = "1vpk5brxs5p4vj02vr0mp0wdily03c3shbyrqz6m85nbxdjhkcd8";
    cs_ver = "4.0.1";
    cs_sha256 = "0ijwxxk71nr9z91yxw20zfj4bbsbrgvixps5c7cpj163xlzlwba6";
  };
  r2-for-cutter = generic {
    version_commit = "21830";
    gittap = "3.5.1";
    gittip = "4ec482ba2d4f554beeafb3aa47758e970bcab937";
    rev = "4ec482ba2d4f554beeafb3aa47758e970bcab937";
    version = "2019-05-15";
    sha256 = "1vpk5brxs5p4vj02vr0mp0wdily03c3shbyrqz6m85nbxdjhkcd8";
    cs_ver = "4.0.1";
    cs_sha256 = "0ijwxxk71nr9z91yxw20zfj4bbsbrgvixps5c7cpj163xlzlwba6";
  };
  #</generated>
}
