{ lib, python3, glibcLocales }:

python3.pkgs.buildPythonApplication rec {
  pname = "csvkit";
  version = "1.0.5";

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "1ffmbzk4rxnl1yhqfl58v7kvl5m9cbvjm8v7xp4mvr00sgs91lvv";
  };

  propagatedBuildInputs = with python3.pkgs; [
    agate agate-excel agate-dbf agate-sql six
  ];

  checkInputs = with python3.pkgs; [
    glibcLocales nose
  ];

  checkPhase = ''
    LC_ALL="en_US.UTF-8" nosetests -e test_csvsql
  '';

  meta = with lib; {
    description = "A suite of command-line tools for converting to and working with CSV";
    maintainers = with maintainers; [ vrthra ];
    license = licenses.mit;
    homepage = https://github.com/wireservice/csvkit;
  };
}
