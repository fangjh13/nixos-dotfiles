{ pkgs, lib, username, community-nur, host, ... }@args:
let
  inherit (import ../hosts/${host}/variables.nix) wallpaper timezone;
  capitalize = str:
    let
      first = builtins.substring 0 1 str;
      rest = builtins.substring 1 (builtins.stringLength str - 1) str;
    in lib.toUpper first + rest;
in {
  imports = [
    ./common.nix
    (import ./stylix.nix (args // { wallpaper = "${wallpaper}"; }))
    ./fonts.nix
    ./ssh.nix
    ./avahi.nix
    ./fhs.nix
  ];

  # enable zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };
  environment.shells = [ pkgs.bashInteractive pkgs.zsh ];

  # NOTE: Define a main user account
  users.users."${username}" = {
    isNormalUser = true;
    description = capitalize "${username}";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [ ];
    shell = pkgs.zsh;
  };
  # given the users in this list the right to specify additional substituters via:
  #    1. `nixConfig.substituers` in `flake.nix`
  #    2. command line args `--options substituers http://xxx`
  nix.settings.trusted-users = [ "${username}" ];

  # customise /etc/nix/nix.conf declaratively via `nix.settings`
  nix.settings = {
    # enable flakes globally
    experimental-features = [ "nix-command" "flakes" ];
    # save disk space use hard links
    auto-optimise-store = true;

    substituters = [
      # cache mirror located in China
      # status: https://mirror.sjtu.edu.cn/
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      # status: https://mirrors.ustc.edu.cn/status/
      "https://mirrors.ustc.edu.cn/nix-channels/store"

      "https://cache.nixos.org"
      "https://hyprland.cachix.org" # hyprland
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" # hyprland
    ];
    builders-use-substitutes = true;
  };

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  nixpkgs.config = {
    # Allow unfree packages
    allowUnfree = true;
    # NOTE: temporarily allow insecure packages
    permittedInsecurePackages = [
      "electron-27.3.11" # for logseq
    ];
    packageOverrides = pkgs: {
      # make `pkgs.nur` available
      nur = import community-nur {
        inherit pkgs;
        nurpkgs = pkgs;
      };
    };
  };

  # Set your time zone.
  time.timeZone = "${timezone}";

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

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.geoclue2.enable = true;
  programs.dconf.enable = true;
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

  services.power-profiles-daemon = { enable = true; };
  security.polkit.enable = true;

  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  # Enable PAM hyprlock to perform authentication
  security.pam.services.hyprlock = { };

  # Bluetooth
  # https://nixos.wiki/wiki/Bluetooth
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
  };
  # use blueman-applet and blueman-manager
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Docs
  documentation = {
    enable = true;
    doc.enable = true;
    man.enable = true;
    info.enable = true;
    dev.enable = true;
  };
}
