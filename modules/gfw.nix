# NOTE: There is a bug in 24.05 stable branch, I made a copy to create systemd.
# https://github.com/NixOS/nixpkgs/issues/314744
# https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/networking/mihomo.nix
{ pkgs, lib, ... }: {
  environment.systemPackages = [ pkgs.mihomo ];

  systemd.services."mihomo" = {
    description = "Mihomo daemon, A rule-based proxy in Go.";
    documentation = [ "https://wiki.metacubex.one/" ];
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = lib.concatStringsSep " " [
        (lib.getExe pkgs.mihomo)
        "-d /var/lib/private/mihomo"
      ];

      DynamicUser = true;
      StateDirectory = "mihomo";

      ### Hardening
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateMounts = true;
      PrivateTmp = true;
      ProcSubset = "pid";
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RestrictNamespaces = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = "@system-service bpf";
      UMask = "0077";
      AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
      PrivateDevices = false;
      PrivateUsers = false;
      RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK";
    };
  };
}
