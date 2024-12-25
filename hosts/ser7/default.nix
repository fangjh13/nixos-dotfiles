# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }@args:

{
  imports = [
    ../../modules/system.nix

    # Use i3
    # FIXME: specify video drivers
    (import ../../modules/i3.nix (args // {
      videoDrivers = [ "amdgpu" ];
      xkbOptions = "ctrl:nocaps,altwin:swap_lalt_lwin";
    }))
    # Or use plasma5
    # ../../modules/plasma5.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Add clash service for freedom
    ../../modules/gfw.nix

    # Add frpc service
    ../../modules/frpc.nix

    # Add Docker
    # ../../modules/docker.nix

  ];

  # FIXME: Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Prevent boot partition running out of disk space
  boot.loader.systemd-boot.configurationLimit = 10;

  # NOTE: AMD Ryzen 7 7840HS w/ Radeon 780M Graphics
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
  environment.systemPackages = with pkgs; [ amdgpu_top ];

  # FIXME: Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.

  # Disable DNS management by NetworkManager
  networking.networkmanager.dns = "none";
  # Set resolvconf to use local DNS servers 127.0.0.1:53
  networking.resolvconf = {
    enable = true;
    useLocalResolver = true;
  };

  networking.enableIPv6 = false; # disable ipv6

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.s = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # FIXME: define your hostname
  networking.hostName = "ser7";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  #i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}

