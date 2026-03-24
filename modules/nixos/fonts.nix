{
  pkgs,
  lib,
  ...
}: {
  fonts = {
    # use fonts specified by user rather than default ones
    # all fonts are linked to /nix/var/nix/profiles/system/sw/share/X11/fonts
    enableDefaultPackages = false;
    fontDir.enable = true;

    packages = import ../public/fonts.nix {inherit pkgs;};

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Noto Serif" "Source Han Serif SC" "Source Han Serif TC"];
        sansSerif = [
          "Noto Sans"
          "Hack Nerd Font Mono"
          "Source Han Sans SC"
          "Source Han Sans TC"
        ];
        monospace = [
          "Noto Sans Mono"
          "Hack Nerd Font Mono"
          "Noto Sans Mono CJK SC"
          "Noto Sans Mono CJK TC"
        ];
        emoji = ["Noto Color Emoji"];
      };
    };
  };
}
