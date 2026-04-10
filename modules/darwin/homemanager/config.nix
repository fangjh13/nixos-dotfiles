{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  files = pkgs.callPackage ./files.nix;
in {
  imports = [
    ../../public/homemanager/programs.nix
    ../../public/homemanager/git
    ../../public/homemanager/shell
    ../../public/homemanager/nvim
    ../../public/homemanager/tmux
    ../../public/homemanager/yazi
    ../../public/homemanager/programming
    ../../public/homemanager/terminals/kitty
    ../../public/homemanager/terminals/wezterm
    ../../public/homemanager/terminals/alacritty
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    enableNixpkgsReleaseCheck = false;
    packages = pkgs.callPackage ./packages.nix {};
    file = lib.mkMerge [
      files
    ];

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "26.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
