{
  pkgs,
  lib,
  ...
}: {
  programs.keepassxc = {
    enable = true;
    autostart = lib.mkIf pkgs.stdenv.isLinux true;
    settings = {
      Browser = {
        Enabled = true;
        UpdateBinaryPath = false;
      };
      browserIntegration.firefox = true;
      browserIntegration.chromium = true;
      browserIntegration.chrome = true;

      GUI = {
        AdvancedSettings = true;
        ApplicationTheme = "dark";
        CompactMode = true;
        MinimizeOnClose = true;
        HidePasswords = true;
        MinimizeToTray = true;
        MonospaceNotes = true;
        ShowTrayIcon = true;
        TrayIconAppearance = "monochrome-light";
      };

      Security = let
        minutes = s: builtins.floor (s * 60);
      in {
        ClearClipboardTimeout = minutes 0.75;
        EnableCopyOnDoubleClick = true;
        IconDownloadFallback = true;
        LockDatabaseIdle = true;
        LockDatabaseIdleSeconds = minutes 10;
      };

      SSHAgent.Enabled = true;
    };
  };
}
