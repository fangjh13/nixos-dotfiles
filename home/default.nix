{
  config,
  lib,
  pkgs,
  username,
  host,
  ...
}: let
  inherit (import ../hosts/${host}/variables.nix) useGUI;
in {
  imports =
    [
      ./common.nix
      ./git
      ./shell
      ./nvim
      ./tmux
      ./yazi
      ./scripts
      ./programming
    ]
    ++ lib.optionals useGUI [
      ./gui
    ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
