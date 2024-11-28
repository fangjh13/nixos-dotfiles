{ pkgs, pkgs-unstable, ... }:

{
  # themes
  home.file.".local/share/fcitx5/themes" = {
    source = ./themes;
    recursive = true;
  };
  xdg.configFile = {
    "fcitx5/profile" = {
      source = ./profile;
      # every time fcitx5 switch input method, it will modify ~/.config/fcitx5/profile,
      # so we need to force replace it in every rebuild to avoid file conflict.
      force = true;
    };
    # apply themes
    "fcitx5/conf/classicui.conf".source = ./conf/classicui.conf;
    "fcitx5/conf/rime.conf".source = ./conf/rime.conf;
  };
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = let
      # fcitx5 rime input method
      local-fcitx5-rime = (pkgs.fcitx5-rime.override {
        # 引入自定义的配置
        rimeDataPkgs = [ ./rime-config ];
      }).overrideAttrs (final: prev: {
        # 支持 lua 脚本
        buildInputs = [ pkgs.fcitx5 pkgs.librime ];
      });
    in with pkgs; [
      local-fcitx5-rime
      fcitx5-configtool
      fcitx5-chinese-addons
    ];
  };
}
