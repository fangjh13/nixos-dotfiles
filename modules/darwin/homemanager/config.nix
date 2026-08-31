{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./dock.nix
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
    ../../public/homemanager/keepassxc
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    enableNixpkgsReleaseCheck = false;
    packages = pkgs.callPackage ./packages.nix {};

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

  # Re-arrange the Dock via dockutil (dock.nix) https://github.com/kcrawford/dockutil
  local.dock = {
    # if not success use `defaults delete com.apple.dock; killall Dock` or `defaults delete com.apple.dock.plist; killall Dock` to reset to default first. https://www.reddit.com/r/macsysadmin/comments/16vcq0m/command_to_reset_the_dock_back_to_default/
    enable = true;
    entries = [
      {path = "/Applications/Google Chrome.app";}
      {path = "${config.home.homeDirectory}/Applications/Home Manager Apps/Ghostty.app";}
      {path = "/System/Applications/Calendar.app";}
      {path = "/System/Applications/Mail.app";}
      {
        path = "${config.home.homeDirectory}/Downloads";
        type = "folder";
        view = "grid";
        display = "stack";
        sort = "datemodified";
      }
    ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
