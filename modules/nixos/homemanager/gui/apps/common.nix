{
  lib,
  pkgs,
  hostContext,
  ...
}: {
  home.packages = let
    inherit (hostContext.settings) apps;
    getPackageByPath = path:
      builtins.foldl' (
        current: part:
          if builtins.isAttrs current && builtins.hasAttr part current
          then builtins.getAttr part current
          else throw "Unknown package `${path}` in hosts/${hostContext.name}/variables.nix apps"
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
        # scale-wechat-bwrap
        # wechat-uos
      ]
      # Packages enabled from the host settings apps list.
      ++ variableAppPackages;
}
