{ stdenv, lib, fetchurl
, cmocka, doxygen, ibm-sw-tpm2, iproute, openssl, perl, pkgconfig, procps
, uthash, which }:

stdenv.mkDerivation rec {
  pname = "tpm2-tss";
  version = "2.3.1";

  src = fetchurl {
    url = "https://github.com/tpm2-software/${pname}/releases/download/${version}/${pname}-${version}.tar.gz";
    sha256 = "1ryy6da3s91ks3m66y3xp6yh3v096kny0f9br74mxf2635n5g5kh";
  };

  nativeBuildInputs = [
    doxygen perl pkgconfig
  ];
  buildInputs = [
    openssl
  ];

  postPatch = "patchShebangs script";

  configureFlags = [
    "--enable-unit"
    "--enable-integration"
  ];

  checkInputs = [
    ibm-sw-tpm2 iproute procps which
    cmocka uthash
  ];

  doCheck = true;

  postInstall = ''
    # Do not install the upstream udev rules, they rely on specific
    # users/groups which aren't guaranteed to exist on the system.
    rm -R $out/lib/udev
  '';

  meta = with lib; {
    description = "OSS implementation of the TCG TPM2 Software Stack (TSS2)";
    homepage = https://github.com/tpm2-software/tpm2-tss;
    license = licenses.bsd2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ delroth ];
  };
}
