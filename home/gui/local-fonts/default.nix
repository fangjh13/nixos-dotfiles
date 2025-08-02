{ pkgs, lib, ... }:
let
  fontPaths = [
    ./monaco # 苹果 Monaco 字体
    ./menlo # 苹果 Menlo 字体
    ./sf_mono # 苹果 SF Mono 字体
    ./MiSans_L3 # 小米生僻字
    ./HarmonyOS_Sans_TC # 华为鸿蒙字体（繁体）
    ./HarmonyOS_Sans_SC # 华为鸿蒙字体（简体）
  ];
in lib.mkMerge ((map ({ name, path }: {
  home.file.".local/share/fonts/${name}".source = "${path}/${name}";
}) (builtins.concatMap (path:
  map (file: {
    name = file;
    path = path;
  }) (builtins.attrNames (builtins.readDir path))) fontPaths))
  ++ [{ home.activation.cacheFonts = "${pkgs.fontconfig}/bin/fc-cache"; }])
