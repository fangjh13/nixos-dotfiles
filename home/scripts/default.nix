{pkgs, ...}: {
  # add custom scripts
  home.packages = with pkgs; [
    (import ./rofi-launcher.nix {inherit pkgs;})
    (import ./notify-show.nix {inherit pkgs;})
  ];
}
