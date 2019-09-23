{ stdenv, substituteAll, fetchFromGitHub, autoreconfHook, libtool, intltool, pkgconfig
, file, findutils
, gtk3, networkmanager, ppp, xl2tpd, strongswan, libsecret
, withGnome ? true, networkmanagerapplet }:

let pname = "NetworkManager-l2tp"; in
stdenv.mkDerivation rec {
  name = "${pname}${if withGnome then "-gnome" else ""}-${version}";
  #version = "1.2.12";
  version = "1.7.0-git";

  src = fetchFromGitHub {
    owner = "nm-l2tp";
    repo = "network-manager-l2tp";
    #rev = version;
    rev = "56d829713132c229f5226e9b6ec4ad48aed513fd";
    sha256 = "00j4r3zk2pcfzcdkvc44n8za7spqwms6i1i4x1vi9f9zsp73gxyv";
  };

  patches = [
    (substituteAll {
      src = ./fix-paths.patch;
      inherit strongswan xl2tpd;
    })
  ];

  buildInputs = [ networkmanager ppp ]
    ++ stdenv.lib.optionals withGnome [ gtk3 libsecret networkmanagerapplet ];

  nativeBuildInputs = [ autoreconfHook libtool intltool pkgconfig file findutils ];

  preConfigure = ''
    intltoolize -f
  '';

  configureFlags = [
    "--without-libnm-glib"
    "--with-gnome=${if withGnome then "yes" else "no"}"
    "--localstatedir=/var"
    "--sysconfdir=$(out)/etc"
    "--enable-absolute-paths"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "L2TP plugin for NetworkManager";
    inherit (networkmanager.meta) platforms;
    homepage = https://github.com/nm-l2tp/network-manager-l2tp;
    license = licenses.gpl2;
    maintainers = with maintainers; [ abbradar obadz ];
  };
}
