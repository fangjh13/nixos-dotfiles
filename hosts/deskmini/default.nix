# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{host, ...} @ args: {
  imports = [
    ../../modules/system.nix

    # import options modules
    ../../modules/options/intel-drivers.nix
    ../../modules/options/amdgpu-drivers.nix
    ../../modules/options/pulseaudio.nix
    ../../modules/options/pipewire.nix
    ../../modules/options/zen-kernel.nix
    (import ../../modules/options/docker.nix
      (args // {storageDriver = "btrfs";}))
    ../../modules/options/podman.nix
    ../../modules/options/nfs.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # NOTE: Enable imported option modules if you need
  # NOTE: This computer is CPU: Intel 8700 and No other GPU
  drivers.intel.enable = true;
  drivers.amdgpu.enable = false;
  multimedia.pipewire.enable = false;
  multimedia.pulseaudio.enable = true;
  # whether use zen kernel
  kernel.zen.enable = true;
  # Docker or Podman
  addon.docker.enable = false;
  addon.podman.enable = true;
  # NFS filesystem
  filesystem.nfs.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Plymouth boot splash screen
  boot.plymouth.enable = true;

  # NOTE: Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.s = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  networking.hostName = "${host}";

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
