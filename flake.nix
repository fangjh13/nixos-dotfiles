{
  description = "Fython's NixOS Configuration";

  inputs = {
    # https://wiki.nixos.org/wiki/FAQ#What_are_channels_and_how_do_they_get_updated?
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05-small";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # NUR community
    community-nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # System-wide colorscheming and typography
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # neovim nightly
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    community-nur,
    ...
  }: let
    # FIXME: change your info
    system = "aarch64-linux"; # support x86_64-linux or aarch64-linux
    host = "vmnixos";
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
  in {
    nixosConfigurations = {
      "${host}" = mkSystem "${host}" {
        system = system;
        username = username;
      };
    };
  };
}
