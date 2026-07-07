{
  lib,
  username,
  ...
}: let
  rimeData = lib.cleanSourceWith {
    src = ../nixos/homemanager/gui/fcitx5/rime-config/share/rime-data;
    filter = path: type: let
      name = builtins.baseNameOf path;
    in
      !(lib.elem name [
        ".git"
        ".gitignore"
      ]);
  };
in {
  home-manager.users.${username}.home.file."Library/Rime" = {
    source = rimeData;
    recursive = true;
  };

  homebrew.casks = [
    "squirrel-app"
  ];

  # Manage macOS input sources for a "Squirrel only" setup.
  #
  # Why this exists:
  # macOS normally insists on keeping at least one built-in keyboard layout,
  # such as ABC. Removing ABC from System Settings is blocked, and if the
  # HIToolbox preference file is edited normally, macOS may write ABC back.
  #
  # How it works:
  # - rewrite ~/Library/Preferences/com.apple.HIToolbox.plist during activation;
  # - keep Squirrel/Rime as the selected input mode;
  # - remove the remembered ABC keyboard layout;
  # - lock the plist with "chflags uchg" so macOS cannot silently restore ABC.
  #
  # Usage:
  # Import this module from a nix-darwin host and make sure Squirrel is installed
  # first, for example via the "squirrel-app" Homebrew cask.
  #
  # Caveats:
  # - To add or change input methods manually, first unlock the plist:
  #     chflags nouchg ~/Library/Preferences/com.apple.HIToolbox.plist
  #   Rebuilding this configuration will lock it again.
  # - A logout/reboot, or restarting TextInputMenuAgent/SystemUIServer, may be
  #   needed before the menu bar reflects the new input source list.
  system.activationScripts.postActivation.text = ''
    echo >&2 "Configuring macOS input sources..."
    su ${lib.escapeShellArg username} -s /bin/sh <<'USERBLOCK'
    set -eu

    domain="com.apple.HIToolbox"
    plist="$HOME/Library/Preferences/$domain.plist"

    mkdir -p "$HOME/Library/Preferences"

    # Rebuilds run against the plist left locked by the previous activation.
    # Unlock before touch/defaults writes, because even touch updates metadata.
    chflags nouchg "$plist" 2>/dev/null || true
    touch "$plist"

    # This array keeps macOS helper input methods available without adding a
    # visible keyboard layout or a duplicate Squirrel menu entry.
    defaults write "$domain" AppleEnabledInputSources -array \
      '{ "Bundle ID" = "com.apple.CharacterPaletteIM"; InputSourceKind = "Non Keyboard Input Method"; }' \
      '{ "Bundle ID" = "com.apple.inputmethod.ironwood"; InputSourceKind = "Non Keyboard Input Method"; }' \
      '{ "Bundle ID" = "com.apple.PressAndHold"; InputSourceKind = "Non Keyboard Input Method"; }'

    # Squirrel belongs here as the selected input mode. This is what keeps Rime
    # active while AppleEnabledInputSources remains free of visible layouts.
    defaults write "$domain" AppleSelectedInputSources -array \
      '{ "Bundle ID" = "com.apple.PressAndHold"; InputSourceKind = "Non Keyboard Input Method"; }' \
      '{ "Bundle ID" = "im.rime.inputmethod.Squirrel"; "Input Mode" = "im.rime.inputmethod.Squirrel.Hans"; InputSourceKind = "Input Mode"; }'

    # Keep the input source history from falling back to ABC after login.
    defaults write "$domain" AppleInputSourceHistory -array \
      '{ "Bundle ID" = "im.rime.inputmethod.Squirrel"; "Input Mode" = "im.rime.inputmethod.Squirrel.Hans"; InputSourceKind = "Input Mode"; }'

    # This key commonly points at com.apple.keylayout.ABC. Removing it prevents
    # macOS from treating ABC as the remembered current keyboard layout.
    defaults delete "$domain" AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null || true

    killall cfprefsd 2>/dev/null || true
    sleep 1
    chflags uchg "$plist"
    USERBLOCK
  '';
}
