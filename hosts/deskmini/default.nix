# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }@args:

{
  imports = [
    ../../modules/system.nix

    # Use i3
    # FIXME: specify video drivers
    # (import ../../modules/i3.nix (args // { videoDrivers = [ "intel" ]; }))
    # or use default
    (import ../../modules/i3.nix (args))

    # plasma5
    # ../../modules/plasma5.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NOTE: CPU: Intel 8700 and No other GPU
  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-media-sdk
        mesa.drivers
      ];
    };
    # intel_gpu_top command
    intel-gpu-tools.enable = true;
  };

  # FIXME: Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable =
    false; # Easiest to use and most distros use this by default.

  networking.enableIPv6 = false; # disable ipv6

  # FIXME: Set static ip, change your interface and ip if you want manual set
  # or comment all set DHCP true auto get IP address and nameservers
  networking.defaultGateway = {
    address = "10.0.0.18";
    interface = "eno2";
  };
  networking.interfaces.eno2.ipv4.addresses = [{
    address = "10.0.0.140";
    prefixLength = 24;
  }];
  networking.nameservers = [ "10.0.0.18" ];
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = false; # disable use DHCP to obtain an IP address
  # networking.interfaces.eno2.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.s = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # FIXME: define your hostname
  networking.hostName = "deskmini";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

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
  system.stateVersion = "24.11"; # Did you read the comment?

}

