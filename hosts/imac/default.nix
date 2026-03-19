{
  self,
  host,
  pkgs,
  username,
  ...
} @ args: {
  imports = [
    ../../modules/public/system.nix
    ../../modules/darwin/dock.nix
    ../../modules/darwin/brew.nix
  ];

  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 2;
      Minute = 0;
    };
    options = "--delete-older-than 30d";
  };

  # touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    stateVersion = 6;
    primaryUser = username;
    configurationRevision = self.rev or self.dirtyRev or null;

    defaults = {
      NSGlobalDomain = {
        InitialKeyRepeat = 15; # Values: 120, 94, 68, 35, 25, 15
        KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2

        #  Enables tap to click
        "com.apple.mouse.tapBehavior" = 1;
      };

      dock = {
        autohide = false;
        show-recents = false;
        # Animate opening applications
        launchanim = true;
        orientation = "bottom";
        tilesize = 48;
      };

      finder = {
        AppleShowAllFiles = true; # hidden files
        AppleShowAllExtensions = true; # file extensions
        _FXShowPosixPathInTitle = true; # title bar full path
        ShowPathbar = true; # breadcrumb nav at bottom
        ShowStatusBar = true; # file count & disk space
      };

      trackpad = {
        Clicking = true;
        # Enable three-finger drag
        TrackpadThreeFingerDrag = true;
      };
    };
  };
}
