{
  pkgs,
  lib,
  pkgs-stable,
  ...
}: {
  programs.keepassxc = {
    package = pkgs-stable.keepassxc;
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
        QuickUnlock = true; # Enables Touch ID / Quick Unlock feature
        LockDatabaseIdle = true; # Auto-lock after idle time
        LockDatabaseIdleSeconds = minutes 10; # Idle timeout in seconds
        LockDatabaseOnScreenLock = true; # Lock when screen locks
        ClearClipboardTimeout = minutes 0.75;
        EnableCopyOnDoubleClick = true;
        IconDownloadFallback = true;
      };

      SSHAgent.Enabled = true;
    };
  };
}
