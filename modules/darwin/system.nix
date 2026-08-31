# Shared Darwin system configuration.
# This module provides baseline settings for all macOS (nix-darwin) hosts.
# Individual hosts can override any value set with `lib.mkDefault`.
{
  lib,
  pkgs,
  config,
  inputs,
  hostContext,
  ...
}: let
  inherit (hostContext) username;
in {
  imports = [
    ../public/system.nix
    ./brew.nix
    ./fonts.nix
  ];

  # Garbage collection
  nix.gc = {
    automatic = lib.mkDefault true;
    interval = lib.mkDefault {
      Weekday = 0;
      Hour = 2;
      Minute = 0;
    };
    options = lib.mkDefault "--delete-older-than 30d";
  };

  # Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = lib.mkDefault true;

  system = {
    stateVersion = lib.mkDefault 6;
    primaryUser = lib.mkDefault username;
    configurationRevision = lib.mkDefault (inputs.self.rev or inputs.self.dirtyRev or null);

    defaults = {
      NSGlobalDomain = {
        InitialKeyRepeat = lib.mkDefault 15; # Values: 120, 94, 68, 35, 25, 15
        KeyRepeat = lib.mkDefault 2; # Values: 120, 90, 60, 30, 12, 6, 2

        # Enables tap to click
        "com.apple.mouse.tapBehavior" = lib.mkDefault 1;
        # Swap mouse middle-button scroll direction, true for natural, false for traditional
        "com.apple.swipescrolldirection" = lib.mkDefault true;
      };

      finder = {
        AppleShowAllFiles = lib.mkDefault true; # hidden files
        AppleShowAllExtensions = lib.mkDefault true; # file extensions
        FXDefaultSearchScope = lib.mkDefault "SCcf"; # search current folder
        _FXShowPosixPathInTitle = lib.mkDefault true; # title bar full path
        ShowPathbar = lib.mkDefault true; # breadcrumb nav at bottom
        ShowStatusBar = lib.mkDefault true; # file count & disk space
      };

      trackpad = {
        # Enable tap to click
        Clicking = lib.mkDefault true;
        # Enable three-finger drag
        TrackpadThreeFingerDrag = lib.mkDefault true;
      };

      CustomUserPreferences = {
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            # https://apple.stackexchange.com/questions/474904/what-does-each-part-in-com-apple-symbolichotkeys-plist-mean
            "64" = {
              # Disable `Command + Space` for Spotlight Search
              enabled = lib.mkDefault false;
            };
          };
        };
      };
    };
  };
}
