{
  inputs,
  hostContext,
  packageSets,
  ...
}: {
  home-manager = {
    # Use the global system level nixpkgs
    useGlobalPkgs = true;
    # Installed into the system-wide /etc/profiles location `/etc/profiles/per-user/<username>`, instead of the default user-specific ~/.nix-profile
    useUserPackages = true;
    users.${hostContext.username} = {
      imports = [
        ./config.nix
        inputs.catppuccin.homeModules.catppuccin
      ];
    };
    # expose some extra arguments in home modules
    extraSpecialArgs = {inherit inputs hostContext packageSets;};
  };
}
