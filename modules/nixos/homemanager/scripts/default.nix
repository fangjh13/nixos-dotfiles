{pkgs, ...}: {
  # add custom CLI scripts
  home.packages = [
    (import ./cpu-temp.nix {inherit pkgs;})
    (import ./memory-top.nix {inherit pkgs;})
  ];
}
