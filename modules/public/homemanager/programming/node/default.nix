{
  lib,
  pkgs,
  ...
}:
# Web Development
{
  home.packages = with pkgs; [
    nodejs # Provides 'node' and 'npm' globally
    yarn # Global yarn
    # pnpm # npm alternative for modern projects
  ];
}
