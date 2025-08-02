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

  outputs = inputs@{ self, nixpkgs, home-manager, community-nur, ... }:
    let
      # FIXME: change your info
      system = "aarch64-linux";  # support x86_64-linux or aarch64-linux
      host = "vm001";
      username = "fython";
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations = {
        "${host}" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit username community-nur pkgs-unstable host; };

          modules = [
            ./hosts/${host}
            # TODO: move to internal hosts
            # inputs.stylix.nixosModules.stylix # stylix modules
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users."${username}" = import ./home;
                extraSpecialArgs = inputs // {
                  inherit username community-nur pkgs-unstable host;
                };
              };
            }
          ];
        };
      };
    };
}
