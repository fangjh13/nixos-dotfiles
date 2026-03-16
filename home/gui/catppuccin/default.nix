{...}: {
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";

    cursors = {
      enable = true;
      accent = "dark";
    };

    # Disable targets that have custom configs
    hyprlock.enable = false;
    firefox.enable = false;
    fcitx5.enable = false;
    delta.enable = false;
    nvim.enable = false;
  };
}
