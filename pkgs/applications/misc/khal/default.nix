{ stdenv, pkgs, python3 }:

with python3.pkgs; buildPythonApplication rec {
  pname = "khal";
  version = "0.10.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1r8bkgjwkh7i8ygvsv51h1cnax50sb183vafg66x5snxf3dgjl6l";
  };

  propagatedBuildInputs = [
    atomicwrites
    click
    click-log
    configobj
    dateutil
    icalendar
    lxml
    pkgs.vdirsyncer
    pytz
    pyxdg
    requests_toolbelt
    tzlocal
    urwid
    pkginfo
    freezegun
  ];
  nativeBuildInputs = [ setuptools_scm ];
  checkInputs = [ pytest pkgs.glibcLocales  /* :( */ ];

  postInstall = ''
    install -D misc/__khal $out/share/zsh/site-functions/__khal

    # bah, fixes tests
    export LC_ALL=en_US.UTF-8
  '';

  doCheck = true;

  checkPhase = ''
    py.test
  '';

  meta = with stdenv.lib; {
    homepage = http://lostpackets.de/khal/;
    description = "CLI calendar application";
    license = licenses.mit;
    maintainers = with maintainers; [ gebner ];
  };
}
