# This module runs frpc as a root LaunchDaemon on macOS. Hosts opt in with
# `addon.frpc.enable` and may override the external configuration path.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.addon.frpc;
  logFile = "/var/log/frpc.log";
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

    # sops-nix installs secrets in postActivation at order 1500. Validate the
    # newly installed generation afterwards instead of reading a stale path.
    system.activationScripts.postActivation.text = lib.mkOrder 1600 ''
      frpc_config=${lib.escapeShellArg cfg.configFile}
      frpc_log_file=${lib.escapeShellArg logFile}

      /usr/bin/touch "$frpc_log_file"
      /usr/sbin/chown root:wheel "$frpc_log_file"
      /bin/chmod 0600 "$frpc_log_file"

      if [[ ! -f "$frpc_config" ]]; then
        echo "error: addon.frpc.configFile is not a regular file: $frpc_config" >&2
        exit 1
      fi

      if [[ ! -r "$frpc_config" ]]; then
        echo "error: addon.frpc.configFile is not readable by root: $frpc_config" >&2
        exit 1
      fi

      frpc_owner=$(/usr/bin/stat -f '%Su' "$frpc_config")
      if [[ "$frpc_owner" != "root" ]]; then
        echo "error: addon.frpc.configFile must be owned by root: $frpc_config" >&2
        exit 1
      fi

      frpc_mode=$(/usr/bin/stat -f '%Lp' "$frpc_config")
      if [[ "$frpc_mode" != "400" && "$frpc_mode" != "600" ]]; then
        echo "error: addon.frpc.configFile must have mode 0400 or 0600: $frpc_config" >&2
        exit 1
      fi

      ${lib.getExe' cfg.package "frpc"} verify -c "$frpc_config"
    '';

    launchd.daemons.frpc = {
      command = lib.escapeShellArgs [
        (lib.getExe' cfg.package "frpc")
        "-c"
        cfg.configFile
      ];

      serviceConfig = {
        UserName = "root";
        GroupName = "wheel";
        RunAtLoad = true;
        KeepAlive = {
          SuccessfulExit = false;
        };
        ProcessType = "Background";
        StandardOutPath = logFile;
        StandardErrorPath = logFile;
        Umask = 63;
      };
    };
  };
}
