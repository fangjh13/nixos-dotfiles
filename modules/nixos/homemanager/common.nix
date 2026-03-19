{
  lib,
  pkgs,
  config,
  ...
}: {
  programs = {
    # pdf viewer
    zathura = {
      enable = true;
      package = pkgs.zathura.override {
        # https://wiki.archlinux.org/title/Zathura
        useMupdf = true;
      };
      options = {selection-clipboard = "clipboard";};
    };
  };

  services = {
    # auto mount usb drives
    udiskie.enable = true;

    # enable OpenSSH private key agent
    ssh-agent.enable = true;
  };
}
