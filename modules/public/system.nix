{
  inputs,
  host,
  username,
  community-nur,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) timezone;
in {
  nix.settings.trusted-users = ["${username}"];

  # customise /etc/nix/nix.conf declaratively via `nix.settings`
  nix.settings = {
    # enable flakes globally
    experimental-features = ["nix-command" "flakes"];
    # save disk space use hard links
    auto-optimise-store = true;

    # add additional substituters via:
    #    1. command line args `--options substituers https://xxx`
    #    2. add address in `nix.settings.substituters` like below
    substituters = [
      # cache mirror located in China
      # status: https://mirror.sjtu.edu.cn/
      # "https://mirror.sjtu.edu.cn/nix-channels/store"
      # status: https://mirrors.ustc.edu.cn/status/
      "https://mirrors.ustc.edu.cn/nix-channels/store"

      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    builders-use-substitutes = true;
  };

  nixpkgs = {
    config = {
      # Allow unfree packages
      allowUnfree = true;
      permittedInsecurePackages = [];
      packageOverrides = pkgs: {
        # make `pkgs.nur` available
        nur = import community-nur {
          inherit pkgs;
          nurpkgs = pkgs;
        };
      };
    };

    # Apply our overlays available globally.
    overlays = let
      path = ../../overlays;
      excludedFiles = ["neovim-nightly.nix"];
      importOverlay = name: let
        overlay = import (path + ("/" + name));
      in
        if builtins.isFunction overlay && builtins.hasAttr "inputs" (builtins.functionArgs overlay)
        then overlay {inherit inputs;}
        else overlay;
    in
      with builtins;
        map importOverlay
        (filter (n:
          (match ".*\\.nix" n
            != null
            || pathExists (path + ("/" + n + "/default.nix")))
          && !(elem n excludedFiles))
        (attrNames (readDir path)));
  };

  # Set your time zone.
  time.timeZone = "${timezone}";
}
