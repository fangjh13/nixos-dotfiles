{
  inputs,
  pkgs,
  config,
  lib,
  username,
  host,
  specialArgs,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    users.${username} = {
      imports = [
        ./config.nix
      ];
    };
    # expose some extra arguments in home modules
    extraSpecialArgs =
      inputs
      // specialArgs;
  };

  # Arranges the Dock
  local.dock = {
    enable = true;
    username = username;
    entries = [
      {path = "/Applications/Safari.app/";}
      {path = "/System/Applications/Messages.app/";}
      {path = "/System/Applications/Notes.app/";}
      {path = "${pkgs.alacritty}/Applications/Alacritty.app/";}
      {path = "/System/Applications/Music.app/";}
      {path = "/System/Applications/Photos.app/";}
      {path = "/System/Applications/Photo Booth.app/";}
      {path = "/System/Applications/System Settings.app/";}
      {
        path = "${config.users.users.${username}.home}/Downloads";
        section = "others";
        options = "--sort name --view grid --display stack";
      }
    ];
  };
}
