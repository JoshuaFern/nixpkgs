{ stdenv, python3Packages, fetchFromGitHub, dialog }:

python3Packages.buildPythonApplication rec {
  pname = "certbot";
  version = "0.36.0";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "17j350618r79fx96rb7sdbh9sfj066x7ar14r514rg4v3w1fpy9a";
  };

  propagatedBuildInputs = with python3Packages; [
    ConfigArgParse
    acme
    configobj
    cryptography
    josepy
    parsedatetime
    psutil
    pyRFC3339
    pyopenssl
    pytz
    six
    zope_component
    zope_interface
  ];
  buildInputs = [ dialog ] ++ (with python3Packages; [ mock gnureadline ]);

  patchPhase = ''
    substituteInPlace certbot/notify.py --replace "/usr/sbin/sendmail" "/run/wrappers/bin/sendmail"
    substituteInPlace certbot/util.py --replace "sw_vers" "/usr/bin/sw_vers"
  '';

  postInstall = ''
    for i in $out/bin/*; do
      wrapProgram "$i" --prefix PYTHONPATH : "$PYTHONPATH" \
                       --prefix PATH : "${dialog}/bin:$PATH"
    done
  '';

  checkInputs = with python3Packages; [ pytest pyyaml ];
  doCheck = false /* integration tests want 'docker', not sure how to disable */;

  meta = with stdenv.lib; {
    homepage = src.meta.homepage;
    description = "ACME client that can obtain certs and extensibly update server configurations";
    platforms = platforms.unix;
    maintainers = [ maintainers.domenkozar ];
    license = licenses.asl20;
  };
}
