{pkgs, ...}: {
  # Catppuccin global config (NixOS level)
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };
}
