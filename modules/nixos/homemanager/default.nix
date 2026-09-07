{
  config,
  inputs,
  hostContext,
  packageSets,
  ...
}: let
  terminalAdapters = import ../profiles/default-terminal.nix;
  desktopTerminal =
    if config.profiles.desktop.defaultTerminal == null
    then null
    else terminalAdapters.${config.profiles.desktop.defaultTerminal};
in {
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
    extraSpecialArgs = {
      inherit inputs hostContext packageSets;
      desktopProfile = config.profiles.desktop;
      inherit desktopTerminal;
    };
  };
}
