{ config, pkgs-unstable, ... }:

{
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = let
      # fcitx5 rime input method
      local-fcitx5-rime = (pkgs-unstable.fcitx5-rime.override {
        # 引入自定义的配置
        rimeDataPkgs = [
          ./rime-data-flypy
        ];
      }).overrideAttrs (final: prev: {
          # 支持 lua 脚本
          buildInputs = [ pkgs-unstable.fcitx5 pkgs-unstable.librime ];
        });
    in with pkgs-unstable; [ 
        local-fcitx5-rime 
        fcitx5-configtool 
        fcitx5-chinese-addons 
      ];
  };
}
