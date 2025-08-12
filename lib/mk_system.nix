# This function creates a NixOS system or Darwin system.
{
  inputs,
  nixpkgs,
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
    ../modules/users-${
      if darwin
      then "darwin"
      else "nixos"
    }.nix;
  # home-manager configuration
  userHMConfig = ../home;

  systemFunc =
    if darwin
    then inputs.darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;
  home-manager =
    if darwin
    then inputs.home-manager.darwinModules
    else inputs.home-manager.nixosModules;

  isLinux = !darwin;
in
  systemFunc rec {
    inherit system;

    # expose some extra arguments so that our modules can use them
    specialArgs = {inherit username community-nur pkgs-unstable host;};

    modules = [
      # Apply our overlays available globally.
      {nixpkgs.overlays = overlays;}

      # Snapd on Linux
      # (
      #   if isLinux
      #   then inputs.nix-snapd.nixosModules.default
      #   else {}
      # )

      # stylix modules
      (
        if isLinux && useGUI
        then inputs.stylix.nixosModules.stylix
        else {}
      )

      # system modules
      hostConfig
      usersConfig

      # home-manager
      home-manager.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${username} = import userHMConfig;
          # expose some extra arguments in home modules
          extraSpecialArgs =
            inputs
            // specialArgs;
        };
      }
    ];
  }
