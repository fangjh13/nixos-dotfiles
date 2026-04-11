{
  pkgs,
  config,
  inputs,
  username,
  host,
  ...
}: {
  imports = [inputs.nix-homebrew.darwinModules.nix-homebrew];

  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;
    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = pkgs.stdenv.hostPlatform.system == "aarch64-darwin";

    # User owning the Homebrew prefix
    user = "${username}";

    # Declarative tap management
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };

    # Enable fully-declarative tap management
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = false;

    # Automatically migrate existing Homebrew installations
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    # like `brew install --cask`
    casks = pkgs.callPackage ./casks.nix {inherit host;};

    onActivation = {
      cleanup = "zap";
      autoUpdate = false;
      upgrade = false;
    };

    # Align homebrew taps config with nix-homebrew reduces configuration mismatches
    taps = builtins.attrNames config.nix-homebrew.taps;

    brews = [
      # like `brew install`
      "mas"
    ];

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)
    masApps = {
      # "wireguard" = 1451685025;
    };
  };
}
