{
  config,
  host,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./secrets
  ];

  # NOTE: Enable addon modules if you need. See modules/darwin/ for available options.
  addon.hammerspoon.enable = false;
  addon.karabiner-elements.enable = false;
  addon.input-method.enable = false;
  addon.ghostty.enable = true;
  addon.frpc.enable = false;
  addon.sing-box.enable = false;
  addon.mihomo.enable = false;

  # Override shared system.defaults if needed. Defaults are in modules/darwin/system.nix.
  # Example: system.defaults.finder._FXShowPosixPathInTitle = false;
}
