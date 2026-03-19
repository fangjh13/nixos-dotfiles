{
  pkgs,
  lib,
  ...
}: {
  programs.uv = {
    enable = true;
    package = pkgs.uv;
  };
}
