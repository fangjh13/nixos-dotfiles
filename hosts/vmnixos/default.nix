{
  config,
  hostContext,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./secrets
  ];

  home-manager.users.${hostContext.username}.imports = [./home.nix];

  time.timeZone = "Asia/Singapore";

  addon.rclone = {
    enable = true;
    mutableConfig = {
      seedFile = config.sops.secrets."rclone-config".path;
      seedVersion = config.sops.secrets."rclone-config".sopsFileHash;
    };
    jobs.pmind = {
      source = "/home/${hostContext.username}/PM";
      destination = "gdrive:backup/PMind";
      extraArgs = ["--exclude" "**/.venv/**" "--exclude" "**/__pycache__/**" "--exclude" "**/.direnv/**" "--exclude" "**/.cache/**" "--exclude" "**/.devspace/**"];
    };
  };

  networking = {
    firewall.enable = false;
    networkmanager.dns = "none";
    nameservers = ["8.8.8.8"];
  };

  system.stateVersion = "24.11";
}
