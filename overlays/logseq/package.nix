{
  appimageTools,
  fetchurl,
  lib,
  makeWrapper,
}: let
  pname = "logseq";
  version = "0.10.15";

  src = fetchurl {
    url = "https://github.com/logseq/logseq/releases/download/${version}/Logseq-linux-x64-${version}.AppImage";
    hash = "sha256-i5EQUvSW1ix+8NT8nCs6mGH2B9xF7G4mB7vBhDJ7JdE=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    nativeBuildInputs = [makeWrapper];

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/Logseq.desktop \
        $out/share/applications/Logseq.desktop
      substituteInPlace $out/share/applications/Logseq.desktop \
        --replace-fail "Exec=Logseq %u" "Exec=logseq %U"

      for size in 16 32 48 64 128 256; do
        install -m 444 -D \
          ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/Logseq.png \
          $out/share/icons/hicolor/''${size}x''${size}/apps/Logseq.png
      done

      wrapProgram $out/bin/logseq \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
    '';

    meta = {
      description = "Privacy-first, open-source platform for knowledge management and collaboration";
      homepage = "https://github.com/logseq/logseq";
      license = lib.licenses.agpl3Only;
      mainProgram = "logseq";
      platforms = ["x86_64-linux"];
    };
  }
