{ stdenv
, buildPythonPackage
, fetchPypi
, pytest
, pkgs
}:

buildPythonPackage rec {
  pname = "libarchive-c";
  version = "2.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "06d44d5b9520bdac93048c72b7ed66d11a6626da16d2086f9aad079674d8e061";
  };

  buildInputs = [ pytest pkgs.glibcLocales ];

  LC_ALL="en_US.UTF-8";

  postPatch = ''
    substituteInPlace libarchive/ffi.py --replace \
      "find_library('archive')" "'${pkgs.libarchive.lib}/lib/libarchive.so'"
  '';

  checkPhase = ''
    py.test tests -k 'not test_check_archiveentry_with_unicode_entries_and_name_zip and not test_check_archiveentry_using_python_testtar'
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/Changaco/python-libarchive-c;
    description = "Python interface to libarchive";
    license = licenses.cc0;
  };

}
