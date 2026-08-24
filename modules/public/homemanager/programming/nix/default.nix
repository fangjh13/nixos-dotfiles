{packageSets, ...}: {
  home.packages = with packageSets.unstable; [
    alejandra
    deadnix
    statix
  ];

  # https://direnv.net/
  programs.direnv = {
    enable = true;
    package = packageSets.unstable.direnv;
    enableZshIntegration = true;
    nix-direnv = {
      enable = true;
      package = packageSets.unstable.nix-direnv;
    };
  };
}
