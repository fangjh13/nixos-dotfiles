{
  lib,
  pkgs,
  host,
  ...
}: {
  home.packages = let
    inherit (import ../../../../../hosts/${host}/variables.nix) apps;
    getPackageByPath = path:
      builtins.foldl' (
        current: part:
          if builtins.isAttrs current && builtins.hasAttr part current
          then builtins.getAttr part current
          else throw "Unknown package `${path}` in hosts/${host}/variables.nix apps"
      )
      pkgs (lib.splitString "." path);
    variableAppPackages = map getPackageByPath apps;
    scale-wechat-bwrap = pkgs.nur.repos.novel2430.wechat-universal-bwrap.overrideAttrs (oldAttrs: {
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          wrapProgram $out/bin/wechat-universal-bwrap \
            --set QT_SCALE_FACTOR 1.5
        '';
    });
  in
    with pkgs;
      [
        libnotify
        wineWow64Packages.wayland
        xdg-utils
        graphviz

        # IM
        scale-wechat-bwrap
        # wechat-uos
      ]
      # Packages enabled from hosts/${host}/variables.nix apps.
      ++ variableAppPackages;
}
