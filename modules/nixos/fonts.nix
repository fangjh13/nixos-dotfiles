{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.profiles.desktop.enable {
    fonts = {
      # use fonts specified by user rather than default ones
      # all fonts are linked to /nix/var/nix/profiles/system/sw/share/X11/fonts
      enableDefaultPackages = false;
      fontDir.enable = true;

      packages = with pkgs;
        import ../public/fonts.nix {inherit pkgs;}
        ++ [
          # Noto means "no tofu", referring to the boxes shown for missing glyphs.
          # Noto family names use Noto + Sans or Serif + the script name.
          # CJK families end with the regional variant: SC, TC, HK, JP, or KR.
          noto-fonts # Common scripts, excluding CJK glyphs
          noto-fonts-cjk-sans # CJK glyphs
          noto-fonts-cjk-serif
          noto-fonts-color-emoji # Color emoji font
          noto-fonts-emoji-blob-bin # Google's legacy blob-style color emoji
          # noto-fonts-extra # Additional weights and width variants

          # Adobe leads the Source family; Adobe and Google jointly developed its CJK fonts.
          # source-sans # Latin sans-serif families and weight variants
          # source-serif # Latin serif families and weight variants
          source-han-sans # CJK sans-serif glyphs
          source-han-serif # CJK serif glyphs
        ];

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
  };
}
