{
  lib,
  pkgs,
  ...
}:
# Web Development
{
  home.packages = with pkgs; [
    nodePackages.nodejs
    nodePackages.yarn
    nodePackages.typescript
  ];
}
