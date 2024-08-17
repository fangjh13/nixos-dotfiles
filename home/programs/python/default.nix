{ lib, pkgs, ... }: {
  # Python 
  home.packages = with pkgs; [ python3 pipx ];
  programs.pyenv = {
    enable = true;
    enableBashIntegration = true;
  };
}
