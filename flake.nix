{
  description = "Fython's NixOS Configuration";

  inputs = {
    # https://wiki.nixos.org/wiki/FAQ#What_are_channels_and_how_do_they_get_updated?
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05-small";
    nixpkgs-poetry.url = "github:nixos/nixpkgs/882842d2a908700540d206baa79efb922ac1c33d";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declarative secret provisioning
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # NUR community
    community-nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Catppuccin theme
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # neovim nightly
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # MacOS configuration
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs @ {nixpkgs, ...}: let
    constructInventory = import ./lib/system-construction.nix {inherit inputs;};
    inventoryOutputs = constructInventory ./hosts;
    inventoryOnboarding = import ./lib/inventory-onboarding.nix {inherit inputs;};
    supportedSystems = import ./lib/supported-systems.nix;
  in {
    apps = nixpkgs.lib.genAttrs supportedSystems (system: {
      init = inventoryOnboarding system;
    });
    inherit (inventoryOutputs) nixosConfigurations darwinConfigurations;
    checks = nixpkgs.lib.genAttrs supportedSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      onboardingApp = inventoryOnboarding system;
      systemConstructionContracts = import ./tests/system-construction-contracts.nix {inherit inputs;};
    in
      inventoryOutputs.checks.${system}
      // {
        inventory-onboarding-app = pkgs.runCommand "inventory-onboarding-app" {} ''
          ${onboardingApp.program} --help > "$out"
        '';
        inventory-onboarding-cli =
          pkgs.runCommand "inventory-onboarding-cli" {
            nativeBuildInputs = [pkgs.bash pkgs.coreutils pkgs.findutils pkgs.git pkgs.gnugrep pkgs.gnused pkgs.hostname];
          } ''
            export INVENTORY_ONBOARDING_TEST_ROOT=1
            export INVENTORY_ONBOARDING_SKIP_REAL_NIX_TEST=1
            bash ${inputs.self}/tests/inventory-onboarding.sh
            touch "$out"
          '';
        system-construction-contracts = builtins.deepSeq systemConstructionContracts (pkgs.runCommand "system-construction-contracts" {} ''
          touch "$out"
        '');
      });
  };
}
