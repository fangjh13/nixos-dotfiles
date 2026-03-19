{
  lib,
  config,
  username,
  ...
}:
with lib; let
  cfg = config.addon.podman;
in {
  options.addon.podman = {enable = mkEnableOption "Enable podman";};

  config = mkIf cfg.enable {
    # Enable common container config files in /etc/containers
    virtualisation.containers.enable = true;
    virtualisation = {
      podman = {
        enable = true;
        # Make the Podman socket available in place of the Docker socket, so Docker tools can find the Podman socket.
        dockerSocket.enable = true;
        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = true;
        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    users.users."${username}" = {
      isNormalUser = true;
      extraGroups = ["podman"];
    };
  };
}
