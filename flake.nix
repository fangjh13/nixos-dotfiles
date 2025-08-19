{
  description = "Fython's NixOS Configuration";

  inputs = {
    # https://wiki.nixos.org/wiki/FAQ#What_are_channels_and_how_do_they_get_updated?
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # NUR community
    community-nur.url = "github:nix-community/NUR";
    # System-wide colorscheming and typography
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nix language server
    nixd.url = "github:nix-community/nixd";
  };

  outputs = inputs @ {
    nixpkgs,
    community-nur,
    ...
  }: let
    # FIXME: change your info
    system = "x86_64-linux"; # support x86_64-linux or aarch64-linux
    host = "deskmini";
    username = "fython";
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    overlays = [];
    mkSystem = import ./lib/mk_system.nix {
      inherit inputs nixpkgs pkgs-unstable community-nur overlays;
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
