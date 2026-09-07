{pkgs, ...}: {
  home.packages = with pkgs; [
    libnotify
    wineWow64Packages.wayland
    xdg-utils
    graphviz

    # IM
    # wechat-uos
  ];
}
