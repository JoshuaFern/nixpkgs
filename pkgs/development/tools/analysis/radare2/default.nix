{stdenv, fetchFromGitHub
, buildPackages
, pkgconfig
, libusb, readline, libewf, perl, zlib, openssl
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
    version_commit, # unused
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

      postPatch = let
        capstone = fetchFromGitHub {
          owner = "aquynh";
          repo = "capstone";
          # version from $sourceRoot/shlr/Makefile
          rev = cs_ver;
          sha256 = cs_sha256;
        };
      in ''
        mkdir -p build/shlr
        cp -r ${capstone} capstone-${cs_ver}
        chmod -R +w capstone-${cs_ver}
        # radare 3.3 compat for radare2-cutter
        (cd shlr && ln -s ../capstone-${cs_ver} capstone)
        tar -czvf shlr/capstone-${cs_ver}.tar.gz capstone-${cs_ver}
        # necessary because they broke the offline-build:
        # https://github.com/radare/radare2/commit/6290e4ff4cc167e1f2c28ab924e9b99783fb1b38#diff-a44d840c10f1f1feaf401917ae4ccd54R258
        # https://github.com/radare/radare2/issues/13087#issuecomment-465159716
        curl() { true; }
        export -f curl
      '';

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
    version_commit = "23470";
    gittap = "4.1.1";
    gittip = "c6d0c4a704eb2e273281857db44d6974cbb2ef26";
    rev = "4.1.1";
    version = "4.1.1";
    sha256 = "0412qkzm11m22i1f6mdpdipgibzdqq7hh42cjc58w571ymjwa2d7";
    cs_ver = "4.0.1";
    cs_sha256 = "0ijwxxk71nr9z91yxw20zfj4bbsbrgvixps5c7cpj163xlzlwba6";
  };
  r2-for-cutter = generic {
    version_commit = "23470";
    gittap = "4.1.1";
    gittip = "c6d0c4a704eb2e273281857db44d6974cbb2ef26";
    rev = "c6d0c4a704eb2e273281857db44d6974cbb2ef26";
    version = "2019-12-20";
    sha256 = "0412qkzm11m22i1f6mdpdipgibzdqq7hh42cjc58w571ymjwa2d7";
    cs_ver = "4.0.1";
    cs_sha256 = "0ijwxxk71nr9z91yxw20zfj4bbsbrgvixps5c7cpj163xlzlwba6";
  };
  #</generated>
}
