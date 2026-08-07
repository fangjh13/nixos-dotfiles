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
  hostVars = import ../hosts/${host}/variables.nix;
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
  sopsModule =
    if darwin
    then inputs.sops-nix.darwinModules.sops
    else inputs.sops-nix.nixosModules.sops;

  isLinux = !darwin;
in
  systemFunc {
    inherit system;

    # expose some extra arguments so that our modules can use them
    specialArgs = {
      inherit inputs pkgs-stable pkgs-unstable community-nur host username hostVars isLinux;
      self = inputs.self;
    };

    modules =
      [
        # Cross-platform secret provisioning
        sopsModule
        ../modules/public/sops.nix
        ../modules/public/secrets/llm

        # catppuccin modules
        (
          if isLinux && (hostVars.useGUI or false)
          then inputs.catppuccin.nixosModules.catppuccin
          else {}
        )

        # Cross-platform services
        ../modules/public/services/frpc.nix
        ../modules/public/services/sing-box.nix
        ../modules/public/services/mihomo.nix
      ]
      ++ nixpkgs.lib.optionals isLinux [
        # Shared NixOS modules
        ../modules/nixos/system.nix
        ../modules/nixos/options
      ]
      ++ nixpkgs.lib.optionals darwin [
        # Shared Darwin modules
        ../modules/darwin/system.nix
        # Optional Darwin modules; each host controls them with an enable option.
        ../modules/darwin/hammerspoon
        ../modules/darwin/karabiner-elements
        ../modules/darwin/input-method.nix
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
