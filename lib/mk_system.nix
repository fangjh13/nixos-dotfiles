# This function creates a NixOS system or Darwin system.
{
  inputs,
  nixpkgs,
  pkgs-stable,
  pkgs-unstable,
  community-nur,
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

    modules =
      [
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
      ]
      ++ nixpkgs.lib.optionals isLinux [
        # Shared NixOS modules
        ../modules/nixos/system.nix
        ../modules/nixos/options
      ]
      ++ nixpkgs.lib.optionals darwin [
        # Optional Darwin modules; each host controls them with an enable option.
        ../modules/darwin/hammerspoon
        ../modules/darwin/karabiner-elements
        ../modules/darwin/input-method.nix
        ../modules/darwin/services/sing-box.nix
      ]
      ++ [
        # system modules
        ../modules/public/options/ghostty.nix
        hostConfig
        usersConfig

        # home-manager
        home-manager.home-manager
        userHMConfig
      ];
  }
