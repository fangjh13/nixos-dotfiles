{
  inputs,
  pkgs,
  config,
  lib,
  username,
  host,
  specialArgs,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = {
      imports = [
        ./config.nix
        inputs.catppuccin.homeModules.catppuccin
      ];
    };
    # expose some extra arguments in home modules
    extraSpecialArgs =
      inputs
      // specialArgs;
  };
}
