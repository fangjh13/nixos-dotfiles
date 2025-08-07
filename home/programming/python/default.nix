{
  lib,
  pkgs,
  ...
}: {
  # Python
  home.packages = with pkgs; [
    (python313.withPackages (pyPkgs: with pyPkgs; [requests]))

    # view csv xls in terminal
    visidata
    # run python applications in isolated environments
    pipx
  ];

  imports = [
    ./poetry.nix # Python dependency management
    ./uv.nix # Python dependency management, written in Rust, so fast
  ];
}
