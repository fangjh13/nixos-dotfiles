{ pkgs-unstable, ... }: {
  home.packages = with pkgs-unstable; [ alejandra deadnix statix ];

  programs.direnv = {
    enable = true;
    package = pkgs-unstable.direnv;
    enableZshIntegration = true;
    nix-direnv = {
      enable = true;
      package = pkgs-unstable.nix-direnv;
    };
  };
}
