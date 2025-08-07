{pkgs, ...}: {
  # add custom scripts
  home.packages = [
    (import ./rofi-launcher.nix {inherit pkgs;})
    (import ./rofi-calc.nix {inherit pkgs;})
    (import ./rofi-wo.nix {inherit pkgs;})
    (import ./rofi-clipboard.nix {inherit pkgs;})
    (import ./notify-show.nix {inherit pkgs;})
    (import ./screenshot.nix {inherit pkgs;})
    (import ./screenlock.nix {inherit pkgs;})
    (import ./hypr-smarttf.nix {inherit pkgs;})
    (import ./cpu-temp.nix {inherit pkgs;})
  ];
}
