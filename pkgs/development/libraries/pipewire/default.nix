{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, doxygen, graphviz, valgrind
, glib, dbus, gst_all_1, alsaLib, ffmpeg, libjack2, udev, libva, xorg
, sbc, SDL2, makeFontsConf, bluez, vulkan-loader, vulkan-headers, pulseaudio
}:

let
  fontsConf = makeFontsConf {
    fontDirectories = [ ];
  };
in stdenv.mkDerivation rec {
  pname = "pipewire";
  version = "0.2.92";

  src = fetchFromGitHub {
    owner = "PipeWire";
    repo = "pipewire";
    rev = version;
    sha256 = "16nhcqnwvhd7zpmq7q9q4yg46pscy5xfs2bm41kfsx3ikggggr1n";
  };

  outputs = [ "out" "lib" "dev" "doc" ];

  nativeBuildInputs = [
    meson ninja pkgconfig doxygen graphviz valgrind
  ];
  buildInputs = [
    glib dbus gst_all_1.gst-plugins-base gst_all_1.gstreamer
    alsaLib ffmpeg libjack2 udev libva xorg.libX11 sbc SDL2
    bluez vulkan-loader vulkan-headers pulseaudio
  ];

  mesonFlags = [
    "-Ddocs=true"
    "-Dgstreamer=true"
  ];

  PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "${placeholder "out"}/lib/systemd/user";

  FONTCONFIG_FILE = fontsConf; # Fontconfig error: Cannot load default config file

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Server and user space API to deal with multimedia pipelines";
    homepage = https://pipewire.org/;
    license = licenses.lgpl21;
    platforms = platforms.linux;
    maintainers = with maintainers; [ jtojnar ];
  };
}
