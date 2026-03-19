{
  pkgs,
  lib,
  host,
  ...
} @ args: let
  inherit (import ../../hosts/${host}/variables.nix) useGUI;
in {
  imports =
    [
      ../../modules/public/system.nix

      ./common.nix
      ./ssh.nix
      ./avahi.nix
      ./fhs.nix
    ]
    ++ lib.optionals useGUI [
      # wayland compositor
      ./wm/hyprland.nix
      ./common-gui.nix
      ./bluetooth.nix
      ./catppuccin.nix
      ./fonts.nix
    ];

  nix.settings = {
    substituters = [
      "https://hyprland.cachix.org" # hyprland
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Allow non-root users to specify the allow_other or allow_root mount options, see mount.fuse3(8).
  programs.fuse.userAllowOther = true;
  # Enable periodic SSD TRIM of mounted partitions in background
  services.fstrim.enable = true;
  # Mount, trash, and other functionalities
  services.gvfs.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    git
    sysstat
    lm_sensors # for `sensors` command
    scrot # screen capture tool, used by i3 blur lock to take a screenshot
    alsa-utils # Sound Architecture utils
  ];

  services.power-profiles-daemon = {enable = true;};
  security.polkit.enable = true;

  services.udev.packages = with pkgs; [gnome-settings-daemon];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
}
