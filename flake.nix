{
  description = "Fython's NixOS Configuration";

  inputs = {
    # https://wiki.nixos.org/wiki/FAQ#What_are_channels_and_how_do_they_get_updated?
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11-small";

    home-manager = {
      url = "github:nix-community/home-manager/master";
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
    };
    # neovim nightly
    neovim-nightly-overlay = {
      # url = "github:nix-community/neovim-nightly-overlay";
      url = "github:nix-community/neovim-nightly-overlay/701c0a6174fde5de4b9424c0d1e5a4306b73baac";
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

  outputs = inputs @ {
    nixpkgs,
    community-nur,
    ...
  }: let
    # NOTE: This is your machine info, modified when you run `nix run .#init`
    system = "x86_64-linux"; # support x86_64-linux or aarch64-linux or aarch64-darwin
    host = "deskmini";
    username = "fython";

    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-stable = import inputs.nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
    mkSystem = import ./lib/mk_system.nix {
      inherit inputs nixpkgs pkgs-stable pkgs-unstable community-nur overlays;
    };
    mkApp = import ./lib/mk_app.nix {
      inherit nixpkgs;
      self = inputs.self;
    };
  in {
    apps = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux" "aarch64-darwin"] (arch: {
      init = mkApp "init.sh" arch;
    });
    nixosConfigurations = {
      "${host}" = mkSystem "${host}" {
        system = system;
        username = username;
      };
    };
    darwinConfigurations = {
      "${host}" = mkSystem "${host}" {
        system = system;
        username = username;
        darwin = true;
      };
    };
  };
}
