{pkgs, ...}: {
  programs.keepassxc = {
    enable = true;
    autostart = true;
    settings = {
      Browser = {
        Enabled = true;
        UpdateBinaryPath = false;
      };
      browserIntegration.firefox = true;

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
