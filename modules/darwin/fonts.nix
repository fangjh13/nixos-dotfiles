{pkgs, ...}: {
  fonts.packages = import ../public/fonts.nix {inherit pkgs;};
}
