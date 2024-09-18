{ lib, pkgs, ... }: {
  # Python 
  home.packages = with pkgs; [
    (python311.withPackages (pyPkgs: with pyPkgs; [ ipython requests ]))
    pipx
  ];
}
