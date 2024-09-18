{ lib, pkgs, ... }: {
  # Python 
  home.packages = with pkgs; [
    (python311.withPackages (pyPkgs: with pyPkgs; [ ipython requests ]))
    # view csv xls in terminal
    visidata
    # run python applications in isolated environments 
    pipx
  ];
}
