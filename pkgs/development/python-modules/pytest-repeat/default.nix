{ lib
, buildPythonPackage
, fetchPypi
, setuptools_scm
, pytest
, fetchpatch
}:

buildPythonPackage rec {
  pname = "pytest-repeat";
  version = "0.8.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1nbdmklpi0ra1jnfm032wz96y9nxdlcr4m9sjlnffwm7n4x43g2j";
  };

  # fixes support for pytest >3.6. Should be droppable during the
  # next bump.
  patches = [
    (fetchpatch {
      url = https://github.com/pytest-dev/pytest-repeat/commit/f94b6940e3651b7593aca5a7a987eb56abe04cb1.patch;
      sha256 = "00da1gmpq9pslcmm8pw93jcbp8j2zymzqdsm6jq3xinkvjpsbmny";
    })
  ];

  buildInputs = [ setuptools_scm ];
  checkInputs = [ pytest ];

  checkPhase = ''
    py.test
  '';

  meta = {
    description = "Pytest plugin for repeating tests";
    homepage = https://github.com/pytest-dev/pytest-repeat;
    maintainers = with lib.maintainers; [ costrouc ];
    license = lib.licenses.mpl20;
  };
}
