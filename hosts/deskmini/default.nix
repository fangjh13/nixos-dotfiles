# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ../../modules/system.nix
      ../../modules/i3.nix
      # ../../modules/plasma5.nix

      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      extraEntries = ''
        menuentry "Windows" {
          search --file --no-floppy --set=root /EFI/Microsoft/Boot/bootmgfw.efi
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
       '';
    };
    efi = {
       canTouchEfiVariables = true;
       efiSysMountPoint = "/boot";
    };
    # Prevent boot partition running out of disk space
    systemd-boot.configurationLimit = 1;
  };

  # CPU: Intel 8700
  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-media-sdk
      ];
    };
    # intel_gpu_top command
    intel-gpu-tools.enable = true;
  };

  networking.enableIPv6 = false;  # disable ipv6
  networking.useDHCP = false; # disable use DHCP to obtain an IP address
  networking.defaultGateway = {
    address = "10.0.0.18";
    interface = "eno2";
    };
  networking.interfaces.eno2.ipv4.addresses = [ {
    address = "10.0.0.140";
    prefixLength = 24;
  } ];
  networking.nameservers = [ "10.0.0.18" ];
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = false;  # Easiest to use and most distros use this by default.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}


