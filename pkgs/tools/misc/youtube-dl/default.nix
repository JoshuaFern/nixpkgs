{ lib, fetchurl, buildPythonPackage
, zip, ffmpeg_4, rtmpdump, phantomjs2, atomicparsley, pycryptodome, pandoc
# Pandoc is required to build the package's man page. Release tarballs contain a
# formatted man page already, though, it will still be installed. We keep the
# manpage argument in place in case someone wants to use this derivation to
# build a Git version of the tool that doesn't have the formatted man page
# included.
, generateManPage ? false
, ffmpegSupport ? true
, rtmpSupport ? true
, phantomjsSupport ? false
, hlsEncryptedSupport ? true
, makeWrapper }:

buildPythonPackage rec {

  pname = "youtube-dl";
  # The websites youtube-dl deals with are a very moving target. That means that
  # downloads break constantly. Because of that, updates should always be backported
  # to the latest stable release.
  version = "2019.09.12";

  src = fetchurl {
    url = "https://yt-dl.org/downloads/${version}/${pname}-${version}.tar.gz";
    sha256 = "0wmc0rl4l08hnz3agh69ld1pcmjs7czg0d2k7mnnlxhwlwi38w56";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ zip ] ++ lib.optional generateManPage pandoc;
  propagatedBuildInputs = lib.optional hlsEncryptedSupport pycryptodome;

  # Ensure these utilities are available in $PATH:
  # - ffmpeg: post-processing & transcoding support
  # - rtmpdump: download files over RTMP
  # - atomicparsley: embedding thumbnails
  makeWrapperArgs = let
      packagesToBinPath =
        [ atomicparsley ]
        ++ lib.optional ffmpegSupport ffmpeg_4
        ++ lib.optional rtmpSupport rtmpdump
        ++ lib.optional phantomjsSupport phantomjs2;
    in [ ''--prefix PATH : "${lib.makeBinPath packagesToBinPath}"'' ];

  setupPyBuildFlags = [
    "build_lazy_extractors"
  ];

  postPatch = ''
    patch -p1 <<EOF
    index 3282f84ee..0fcac8c2b 100644
    --- a/youtube_dl/extractor/nbc.py
    +++ b/youtube_dl/extractor/nbc.py
    @@ -91,7 +91,13 @@ class NBCIE(AdobePassIE):
                     'fields[shows]': 'shortTitle',
                     'include': 'show.shortTitle',
                 })
    -        video_data = response['data'][0]['attributes']
    +        try:
    +            video_data = response['data'][0]['attributes']
    +        except:
    +            video_data = dict()
    +            video_data['guid'] = video_id
    +            video_data['title'] = 'none'
    +
             query = {
                 'mbr': 'true',
                 'manifest': 'm3u',
    EOF
  '';

  postInstall = ''
    patchShebangs devscripts/zsh-completion.py
    devscripts/zsh-completion.py
    mkdir -p $out/share/zsh/site-functions
    cp youtube-dl.zsh $out/share/zsh/site-functions/_youtube-dl
  '';

  # Requires network
  doCheck = false;

  meta = with lib; {
    homepage = https://rg3.github.io/youtube-dl/;
    repositories.git = https://github.com/rg3/youtube-dl.git;
    description = "Command-line tool to download videos from YouTube.com and other sites";
    longDescription = ''
      youtube-dl is a small, Python-based command-line program
      to download videos from YouTube.com and a few more sites.
      youtube-dl is released to the public domain, which means
      you can modify it, redistribute it or use it however you like.
    '';
    license = licenses.publicDomain;
    platforms = with platforms; linux ++ darwin;
    maintainers = with maintainers; [ bluescreen303 phreedom AndersonTorres fuuzetsu fpletz enzime ];
  };
}
