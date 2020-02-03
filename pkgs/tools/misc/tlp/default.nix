{ stdenv, lib, fetchFromGitHub, perl, makeWrapper, file, systemd, iw, rfkill
, hdparm, ethtool, inetutils , kmod, pciutils, smartmontools
, x86_energy_perf_policy, gawk, gnugrep, coreutils, utillinux
, debian-devscripts /*checkbashisms*/ , shellcheck
, enableRDW ? false, networkmanager
}:

let
  paths = lib.makeBinPath
          ([ iw rfkill hdparm ethtool inetutils systemd kmod pciutils smartmontools
             x86_energy_perf_policy gawk gnugrep coreutils utillinux
           ]
           ++ lib.optional enableRDW networkmanager
          );

in stdenv.mkDerivation rec {
  pname = "tlp";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "linrunner";
    repo = "TLP";
    rev = version;
    sha256 = "1bgx9psgx9izvhi0y76ayik6ymxsbj3rb9a0y4l1sxx1b4smixg8";
  };

  patches = [
    ./balance_power.patch
  ];

  outRef = placeholder "out";

  makeFlags = [
    "DESTDIR=${outRef}"
    "TLP_SBIN=${outRef}/bin"
    "TLP_BIN=${outRef}/bin"
    "TLP_TLIB=${outRef}/share/tlp"
    "TLP_FLIB=${outRef}/share/tlp/func.d"
    "TLP_ULIB=${outRef}/lib/udev"
    "TLP_NMDSP=${outRef}/etc/NetworkManager/dispatcher.d"
    "TLP_SHCPL=${outRef}/share/bash-completion/completions"
    "TLP_MAN=${outRef}/share/man"
    "TLP_META=${outRef}/share/metainfo"
    "TLP_CONFDEF=${outRef}/share/tlp/defaults.conf"

    "TLP_NO_INIT=1"
  ];

  nativeBuildInputs = [ makeWrapper file ];

  buildInputs = [ perl ];

  installTargets = [ "install-tlp" "install-man" ] ++ stdenv.lib.optional enableRDW "install-rdw";

  checkInputs = [
    #checkbashisms
    debian-devscripts
    shellcheck
  ];

  doCheck = true;
  checkTarget = [ "checkall" ];

  postInstall = ''
    cp -r $out/$out/* $out
    rm -rf $out/$(echo "$NIX_STORE" | cut -d "/" -f2)

    for i in $out/bin/* $out/lib/udev/tlp-* ${lib.optionalString enableRDW "$out/etc/NetworkManager/dispatcher.d/*"}; do
      if file "$i" | grep -q Perl; then
        # Perl script; use wrapProgram
        wrapProgram "$i" \
          --prefix PATH : "${paths}"
      else
        # Bash script
        sed -i '2iexport PATH=${paths}:$PATH' "$i"
      fi
    done
  '';

  meta = with stdenv.lib; {
    description = "Advanced Power Management for Linux";
    homepage = https://linrunner.de/en/tlp/docs/tlp-linux-advanced-power-management.html;
    platforms = platforms.linux;
    maintainers = with maintainers; [ abbradar ];
    license = licenses.gpl2Plus;
  };
}
