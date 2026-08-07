# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  pkgs,
  host,
  username,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./secrets
  ];

  # NOTE: Enable imported option modules if you need
  drivers.intel.enable = false;
  drivers.amdgpu.enable = false;
  # Enable sound with pipwire or pulseaudio. If you are not experiencing strange problems please use the more advanced pirewire
  multimedia.pipewire.enable = false;
  multimedia.pulseaudio.enable = false;
  # whether use zen kernel
  kernel.zen.enable = false;
  # Docker or Podman
  addon.docker.enable = false;
  addon.podman.enable = false;
  # NFS filesystem
  filesystem.nfs.enable = false;
  # Rclone scheduled uploads
  addon.rclone = {
    enable = true;
    configFile = "/var/lib/rclone/rclone.conf";
    mutableConfig = {
      seedFile = config.sops.secrets."rclone-config".path;
      seedVersion = config.sops.secrets."rclone-config".sopsFileHash;
    };
    jobs.pmind = {
      source = "/home/${username}/PM";
      destination = "gdrive:backup/PMind";
      extraArgs = ["--exclude" "**/.venv/**" "--exclude" "**/__pycache__/**" "--exclude" "**/.direnv/**" "--exclude" "**/.cache/**"];
    };
  };
  addon.mihomo.enable = false;
  # Ghostty terminal
  addon.ghostty.enable = false;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Plymouth boot splash screen
  boot.plymouth.enable = true;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.
  networking.hostName = "${host}";

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.s = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  networking.networkmanager.dns = "none"; # Prevents NetworkManager from overriding DNS
  networking.nameservers = [
    "8.8.8.8"
    # "192.168.10.146"
  ];
  # networking.defaultGateway = {
  #   address = "192.168.10.146";
  #   interface = "ens160";
  # };

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
