{ stdenv, fetchurl, fetchFromGitHub, gcc, flex, bison, texinfo, makeWrapper ,
readline, jdk, erlang, autoconf, automake, libtool, pkgconfig }:


let
  mkMercury = stdenv.lib.makeOverridable mkMercury';
  mkMercury' = args @ { src, version, enableMinimal ? false, compilers ? [ gcc ], bootstrapMercury ? null, ... }:
    stdenv.mkDerivation (args // rec {
      name    = "mercury-${if enableMinimal then "minimal-" else ""}${version}";
      inherit src version;

      nativeBuildInputs = (args.nativeBuildInputs or []) ++ [
        flex bison texinfo makeWrapper
        bootstrapMercury 
      ];
      buildInputs = (args.buildInputs or [])
        ++ compilers ++ [ readline ];

      patchPhase = (args.patchPhase or "") + ''
        # Fix calls to programs in /bin
        for p in uname pwd ; do
          for f in $(egrep -lr /bin/$p *) ; do
            sed -i 's@/bin/'$p'@'$p'@g' $f ;
          done
        done
      '';

      preConfigure = (args.preConfigure or "") + ''
        mkdir -p $out/lib/mercury/cgi-bin
      '';

      configureFlags = (args.configureFlags or []) ++ [
        (
          if enableMinimal
          then "--enable-minimal-install"
          else "--enable-deep-profiler=${placeholder "out"}/lib/mercury/cgi-bin"
        )
      ];

      preBuild = (args.preBuild or "") + ''
        # Mercury buildsystem does not take -jN directly.
        makeFlags="PARALLEL=-j$NIX_BUILD_CORES" ;
      '';

      postInstall = (args.postInstall or "") + ''
        # Wrap with compilers for the different targets.
        for e in $(ls $out/bin) ; do
          wrapProgram $out/bin/$e \
            --prefix PATH ":" "${stdenv.lib.makeBinPath compilers}"
        done
      '';

      meta = {
        description = "A pure logic programming language";
        longDescription = ''
          Mercury is a logic/functional programming language which combines the
          clarity and expressiveness of declarative programming with advanced
          static analysis and error detection features.  Its highly optimized
          execution algorithm delivers efficiency far in excess of existing logic
          programming systems, and close to conventional programming systems.
          Mercury addresses the problems of large-scale program development,
          allowing modularity, separate compilation, and numerous optimization/time
          trade-offs.
        '';
        homepage    = "http://mercurylang.org";
        license     = stdenv.lib.licenses.gpl2;
        platforms = stdenv.lib.platforms.linux;
        maintainers = [ ];
      };
    });

in rec {
  mercury-14 = mkMercury rec {
    version = "14.01.1";
    src = fetchurl {
      url    = "https://dl.mercurylang.org/release/mercury-srcdist-${version}.tar.gz";
      sha256 = "12z8qi3da8q50mcsjsy5bnr4ia6ny5lkxvzy01a3c9blgbgcpxwq";
    };
  };
  mercury-14-bootstrap = mercury-14.override { enableMinimal = true; };
  mercury-14-full = mercury-14.override { compilers = [ gcc erlang jdk ]; };
  mercury-rotd = mkMercury rec {
    version = "rotd-2018-10-19";
    src = fetchurl {
      url = "https://dl.mercurylang.org/rotd/mercury-srcdist-${version}.tar.gz";
      sha256 = "1drn1jp4xc263zwpjzcdbjgh24c03n8dhxpq5nmg8cy4sh36dg9q";
    };
  };
  mercury-rotd-bootstrap = mercury-rotd.override { enableMinimal = true; };
  mercury-git = mkMercury {
    version = "2018-10-19";
    src = fetchFromGitHub {
      owner = "Mercury-Language";
      repo = "mercury";
      rev = "3cf72e496ab4d28ceb18c0564f5ba31d3d72c89a";
      sha256 = "0j5mk47qksa74gvvj84myhh0lb5i6d8vd3x4iiikwx9y5qa9pgks";
      fetchSubmodules = true;
    };
    bootstrapMercury = mercury-rotd-bootstrap;
    nativeBuildInputs = [
      autoconf automake libtool pkgconfig
    ];
    preConfigure = ''
      touch boehm_gc/.git
      ./prepare.sh
    '';
  };
}
