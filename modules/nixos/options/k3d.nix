# Disposable local Kubernetes clusters backed by Docker.
#
# Hosts opt in with:
#
#   addon.k3d.enable = true;
#
# Enabling this module installs the k3d CLI and enables the repository's
# Docker module through the `addon.docker` by default. Docker remains
# socket-activated, so enabling k3d does not start the daemon at boot.
# Cluster lifecycle remains project-owned: creating a cluster during NixOS
# activation would leave mutable development state coupled to system rebuilds.
#
# The module deliberately does not create clusters during NixOS activation.
# Create and delete project-specific clusters explicitly, for example:
#
# ```shell
# k3d cluster create dev
# k3d cluster delete dev
# ```
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.addon.k3d;
in {
  options.addon.k3d = {
    enable = lib.mkEnableOption "local k3d Kubernetes development clusters";

    package = lib.mkPackageOption pkgs "k3d" {};
  };

  config = lib.mkIf cfg.enable {
    # Local k3d clusters use the Docker API to manage their K3s node
    # containers, so Docker is a required dependency rather than a parallel
    # runtime choice.
    addon.docker.enable = true;

    environment.systemPackages = [cfg.package];
  };
}
