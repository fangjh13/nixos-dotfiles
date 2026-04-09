{
  inputs,
  pkgs,
  host,
  config,
  username,
  ...
}: {
  users.users.${username} = {
    name = "${username}";
    home = "/Users/${username}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };

  # Re-arrange the Dock via dockutil (dock.nix)
  # https://github.com/kcrawford/dockutil
  local.dock = {
    # if not success use `defaults delete com.apple.dock; killall Dock` or `defaults delete com.apple.dock.plist; killall Dock` to reset to default first. https://www.reddit.com/r/macsysadmin/comments/16vcq0m/command_to_reset_the_dock_back_to_default/
    enable = true;
    username = username;
    entries = [
      {path = "/Applications/Google Chrome.app/";}
      {path = "${config.users.users.${username}.home}/Applications/Home Manager Apps/kitty.app";}
      {path = "/System/Applications/Calendar.app/";}
      {path = "/System/Applications/Mail.app/";}
      {
        path = "${config.users.users.${username}.home}/Downloads";
        section = "others";
        options = "--sort name --view grid --display stack";
      }
    ];
  };
}
