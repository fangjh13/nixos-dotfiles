{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.addon.frpc;
in {
  options.addon.frpc = {
    enable = lib.mkEnableOption "frp client system service";

    package = lib.mkPackageOption pkgs "frp" {};

    configFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/private/frp/frpc.toml";
      example = "/run/secrets/frpc-config";
      description = "Absolute path to the frpc configuration file.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/" cfg.configFile;
        message = "addon.frpc.configFile must be an absolute path.";
      }
    ];

    environment.systemPackages = [cfg.package];

    systemd.services.frpc = {
      description = "frp client";
      requires = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      preStart = ''
        ${lib.getExe' cfg.package "frpc"} verify -c ${lib.escapeShellArg cfg.configFile}
      '';

      serviceConfig = {
        ExecStart = lib.escapeShellArgs [
          (lib.getExe' cfg.package "frpc")
          "-c"
          cfg.configFile
        ];
        Restart = "on-failure";
        RestartSec = 5;
        StartLimitBurst = 99;
      };
    };
  };
}
