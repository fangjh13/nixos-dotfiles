# QT (themed by Catppuccin via Kvantum)
{pkgs, ...}: {
  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kvantum";
  };
}
