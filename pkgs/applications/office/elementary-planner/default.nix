{ stdenv, fetchFromGitHub
, meson, ninja
, evolution-data-server
, libunity
, libical
, libgee
, json-glib
, geoclue2
, sqlite
, libsoup
, gtk3
, pantheon /* granite */
}:

stdenv.mkDerivation rec {
  pname = "planner";
  version = "2019-06-25";
  src = fetchFromGitHub {
    owner = "alainm23";
    repo = pname;
    rev = "f2616654bc002b765665b32cacaa8bb1f4701d21";
    sha256 = "1111111111111111111111111111111111111111111111111111";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    evolution-data-server
    libunity
    libical
    json-glib
    geoclue2
    sqlite
    libsoup
    gtk3
    libgee
    pantheon.granite
  ];

  meta = with stdenv.lib; {
    description = "Task and project manager designed to elementary OS";
    homepage = https://github.com/alainm23/planner;
    license = licenses.gpl3;
    maintainers = with maintainers; [ dtzWill ];
  };
}

