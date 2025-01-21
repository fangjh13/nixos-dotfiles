{ pkgs-unstable, lib, ... }: {
  services.mihomo = {
    package = pkgs-unstable.mihomo;
    enable = true;
    tunMode = true;
    configFile = "/var/lib/private/mihomo/config.yaml";
  };
  # my config file use DNS need listen port 53 privilege
  # https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/networking/mihomo.nix#L109-L110
  systemd.services."mihomo".serviceConfig.AmbientCapabilities =
    lib.mkForce "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
  systemd.services."mihomo".serviceConfig.CapabilityBoundingSet =
    lib.mkForce "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
}
