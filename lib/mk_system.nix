# This function creates a NixOS system or Darwin system.
{
  inputs,
  nixpkgs,
  pkgs-stable,
  pkgs-unstable,
  community-nur,
  overlays,
}: host: {
  system,
  username,
  darwin ? false,
}: let
  inherit (import ../hosts/${host}/variables.nix) useGUI;
  # different configurations for each host
  hostConfig = ../hosts/${host};
  # main user configuration
  usersConfig =
    ../modules/${
      if darwin
      then "darwin"
      else "nixos"
    }/users.nix;
  # home-manager configuration
  userHMConfig =
    ../modules/${
      if darwin
      then "darwin"
      else "nixos"
    }/homemanager;

  systemFunc =
    if darwin
    then inputs.nix-darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;
  home-manager =
    if darwin
    then inputs.home-manager.darwinModules
    else inputs.home-manager.nixosModules;

  isLinux = !darwin;
in
  systemFunc {
    inherit system;

    # expose some extra arguments so that our modules can use them
    specialArgs = {
      inherit inputs pkgs-stable pkgs-unstable community-nur host username;
      self = inputs.self;
    };

    modules = [
      # Apply our overlays available globally.
      {nixpkgs.overlays = overlays;}

      # Snapd on Linux
      # (
      #   if isLinux
      #   then inputs.nix-snapd.nixosModules.default
      #   else {}
      # )

      # catppuccin modules
      (
        if isLinux && useGUI
        then inputs.catppuccin.nixosModules.catppuccin
        else {}
      )

      # system modules
      hostConfig
      usersConfig

      # home-manager
      home-manager.home-manager
      userHMConfig
    ];
  }
