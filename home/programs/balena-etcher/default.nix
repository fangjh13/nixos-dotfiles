{ config, pkgs, ... }:
let
  # https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-appimageTools
  balenaEtcher = with pkgs; appimageTools.wrapType2
    (rec {
      pname = "balenaEtcher";
      version = "1.18.11";
      src = fetchurl {
        sha256 = "sha256-+Hu70UOcmLX4dPOYEBA2adBdX/C8Ryp/17bvi+jUfVA=";
        url = "https://github.com/balena-io/etcher/releases/download/v${version}/balenaEtcher-${version}-x64.AppImage";
      };
      extraPkgs = pkgs: with pkgs; [];
    });
  icons = ./icon.png;
in
{
  home.packages = with pkgs; [
    balenaEtcher
  ];
  # https://www.reddit.com/r/archlinux/comments/xf5pkt/comment/j3wf4gq/
  home.file = {
    ".local/share/applications/balenaEtcher.desktop".text = ''
      [Desktop Entry]
      Version=1.18.11
      Type=Application
      Name=balenaEtcher
      Exec=balenaEtcher --in-process-gpu
      Icon=${icons}
      StartupWMClass=AppRun
    '';
  };
}

