{
  description = "Fython's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # bat theme
    catppuccin-bat = {
      url =
        "github:catppuccin/bat?rev=d3feec47b16a8e99eabb34cdfbaa115541d374fc";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      # FIXME replace your username
      username = "fython";
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        deskmini = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit username;
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };

          modules = [
            ./hosts/deskmini
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users."${username}" = import ./home;
                extraSpecialArgs = inputs // {
                  inherit username;
                  pkgs-unstable = import inputs.nixpkgs-unstable {
                    inherit system;
                    config.allowUnfree = true;
                  };
                };
              };
            }
          ];
        };
      };
    };
}
