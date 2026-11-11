{
  pkgs,
  lib,
  config,
  packageSets,
  ...
}: let
  # KeePassXC expects its config file to be writable at runtime.
  # Home Manager's `programs.keepassxc.settings` creates a read-only symlink
  # into the Nix store, which causes "Access error for config file" warnings.
  # Instead, we generate the INI content ourselves and use an activation script
  # to copy it as a mutable file, so KeePassXC can write to it freely.
  iniFormat = pkgs.formats.ini {};

  keepassxcSettings = {
    Browser = {
      Enabled = true;
      UpdateBinaryPath = false;
    };
    browserIntegration = {
      firefox = true;
      chromium = true;
      chrome = true;
    };

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

  settingsFile = iniFormat.generate "keepassxc.ini" keepassxcSettings;

  configDir =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "${config.home.homeDirectory}/Library/Application Support/KeePassXC"
    else "${config.xdg.configHome}/keepassxc";
in {
  programs.keepassxc = {
    package = packageSets.stable.keepassxc;
    enable = true;
    autostart = lib.mkIf pkgs.stdenv.hostPlatform.isLinux true;
    # Do NOT set `settings` here — it creates a read-only symlink that
    # KeePassXC cannot write to, causing runtime access errors.
  };

  # Copy the Nix-generated INI as a mutable file if it doesn't already exist,
  # so KeePassXC can modify it at runtime while still getting sane defaults.
  home.activation.keepassxcConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    configDir="${configDir}"
    configFile="$configDir/keepassxc.ini"

    mkdir -p "$configDir"

    # Remove Home Manager's read-only symlink if present
    if [ -L "$configFile" ]; then
      rm "$configFile"
    fi

    # Only write defaults when the config file doesn't exist yet,
    # preserving any runtime changes the user has made via the GUI.
    if [ ! -f "$configFile" ]; then
      cp "${settingsFile}" "$configFile"
      chmod 644 "$configFile"
    fi
  '';
}
