{ stdenv, fetchFromGitHub, gtk3 }:

stdenv.mkDerivation rec {
  name = "papirus-icon-theme-${version}";
  version = "20181007";

  src = fetchFromGitHub {
    owner = "PapirusDevelopmentTeam";
    repo = "papirus-icon-theme";
    rev = "7fa490415be36535935074b93d6f70a37dd59232";
    sha256 = "1hv526k0ykq2yj9f6bcl711sgdxwx5y0yqjf5acpvcmx9pm58vz5";
  };

  nativeBuildInputs = [ gtk3 ];

  installPhase = ''
     mkdir -p $out/share/icons
     mv {,e}Papirus* $out/share/icons
  '';

  postFixup = ''
    for theme in $out/share/icons/*; do
      gtk-update-icon-cache $theme
    done
  '';

  meta = with stdenv.lib; {
    description = "Papirus icon theme";
    homepage = https://github.com/PapirusDevelopmentTeam/papirus-icon-theme;
    license = licenses.lgpl3;
    platforms = platforms.all;
  };
}
