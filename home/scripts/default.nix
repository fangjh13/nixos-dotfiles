{ pkgs, ... }: {
  # add custom scripts
  home.packages = [
    (import ./rofi-launcher.nix { inherit pkgs; })
    (import ./notify-show.nix { inherit pkgs; })
  ];
}
