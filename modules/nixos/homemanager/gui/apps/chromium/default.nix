{
  pkgs,
  config,
  ...
}: {
  programs = {
    chromium = {
      enable = true;
      commandLineArgs = [
        "--enable-features=TouchpadOverscrollHistoryNavigation,WaylandLinuxDrmSyncobj"
        "--ozone-platform=wayland"
      ];
      extensions = [
        # {id = "";}  // extension id, query from chrome web store
      ];
    };
  };
}
