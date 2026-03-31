{
  lib,
  pkgs,
  config,
  pkgs-unstable,
  ...
}: {
  home.packages = let
    scale-wechat-bwrap = pkgs.nur.repos.novel2430.wechat-universal-bwrap.overrideAttrs (oldAttrs: {
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          wrapProgram $out/bin/wechat-universal-bwrap \
            --set QT_SCALE_FACTOR 1.5
        '';
    });
  in
    with pkgs; [
      libnotify
      wineWow64Packages.wayland
      xdg-utils
      graphviz

      # productivity
      obsidian
      libreoffice

      # IDE
      code-cursor # AI Code Editor
      antigravity-fhs # Google AI Code Editor

      # database GUI
      jetbrains.datagrip

      gpu-viewer

      # Synology Drive Client
      synology-drive-client
      # notebook
      logseq

      # IM
      scale-wechat-bwrap
      # wechat-uos
      telegram-desktop
    ];
}
