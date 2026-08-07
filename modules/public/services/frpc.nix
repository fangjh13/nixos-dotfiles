# This module runs frpc as a system service (LaunchDaemon on macOS, systemd on NixOS).
# Hosts opt in with `addon.frpc.enable = true;` and may override `secretName` or `configFile`.
#
# Usage in host configuration:
#   addon.frpc.enable = true;
#
# Secret provisioning (sops-nix):
# Since the frpc configuration varies per host, you should define a sops secret bound to the 
# `frpc-config` key in the host's `secrets/default.nix`.
#
# Example in `hosts/my-host/secrets/default.nix`:
#
#   sops.secrets."frpc-config" = {
#     sopsFile = ./frpc.toml;
#     format = "binary"; # Preserves the original file structure and formatting
#   };
#
# To create or edit the encrypted host-specific configuration interactively:
#
#   sops --input-type binary --output-type binary hosts/my-host/secrets/frpc.toml
#
# After changing age or SSH/PGP recipients in .sops.yaml, rewrap the existing data key:
#
#   sops updatekeys --input-type binary hosts/my-host/secrets/frpc.toml
#
# Runtime paths:
#   Config: /run/secrets/frpc-config or /var/lib/private/frp/frpc.toml
#   Logs:   /var/log/frpc.log (macOS) / journalctl (NixOS)
#
# Common operations (macOS):
#   sudo launchctl print system/org.nixos.frpc
#   sudo launchctl kickstart -k system/org.nixos.frpc
#   sudo tail -f /var/log/frpc.log
#
# Common operations (NixOS):
#   sudo systemctl status frpc
#   sudo systemctl restart frpc
#   sudo journalctl -u frpc -f
{
  config,
  lib,
  pkgs,
  isLinux ? true,
  ...
}: let
  cfg = config.addon.frpc;
  isDarwin = !isLinux;

  logFile = "/var/log/frpc.log";

  effectiveConfigFile =
    if cfg.configFile != null
    then cfg.configFile
    else "/dev/null";
in {
  options.addon.frpc = {
    enable = lib.mkEnableOption "frp client system service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.frp;
      description = "The frp package to use.";
    };

    useSopsSecret = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically bind to sops secret configuration path.";
    };

    secretName = lib.mkOption {
      type = lib.types.str;
      default = "frpc-config";
      description = "Name of the sops secret key.";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default =
        if cfg.useSopsSecret
        then config.sops.secrets."${cfg.secretName}".path
        else null;
      defaultText = lib.literalExpression ''if config.addon.frpc.useSopsSecret then config.sops.secrets.''${config.addon.frpc.secretName}.path else null'';
      example = "/etc/frp/frpc.toml";
      description = "Absolute path to frpc configuration file. Overrides sops secret when set.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.configFile != null;
          message = "addon.frpc requires configFile to be set (or useSopsSecret = true).";
        }
        {
          assertion = effectiveConfigFile != "/dev/null" && lib.hasPrefix "/" effectiveConfigFile;
          message = "addon.frpc.configFile must be an absolute path.";
        }
      ];

      # Lazy secret provisioning
      sops.secrets = lib.optionalAttrs cfg.useSopsSecret {
        "${cfg.secretName}" = {
          format = lib.mkOptionDefault "binary";
          owner = lib.mkOptionDefault "root";
          mode = lib.mkOptionDefault "0400";
        };
      };
    }

    # Darwin (macOS launchd) implementation
    (lib.optionalAttrs isDarwin {
      environment.systemPackages = [cfg.package];

      system.activationScripts.postActivation.text = lib.mkOrder 1600 ''
        frpc_config=${lib.escapeShellArg effectiveConfigFile}
        frpc_log_file=${lib.escapeShellArg logFile}

        : > "$frpc_log_file"
        /usr/sbin/chown root:wheel "$frpc_log_file"
        /bin/chmod 0600 "$frpc_log_file"

        if [[ ! -f "$frpc_config" ]]; then
          echo "error: addon.frpc config file is not a regular file: $frpc_config" >&2
          exit 1
        fi

        if [[ ! -r "$frpc_config" ]]; then
          echo "error: addon.frpc config file is not readable by root: $frpc_config" >&2
          exit 1
        fi

        frpc_owner=$(/usr/bin/stat -f '%Su' "$frpc_config")
        if [[ "$frpc_owner" != "root" ]]; then
          echo "error: addon.frpc config file must be owned by root: $frpc_config" >&2
          exit 1
        fi

        frpc_mode=$(/usr/bin/stat -f '%Lp' "$frpc_config")
        if [[ "$frpc_mode" != "400" && "$frpc_mode" != "600" ]]; then
          echo "error: addon.frpc config file must have mode 0400 or 0600: $frpc_config" >&2
          exit 1
        fi

        ${lib.getExe' cfg.package "frpc"} verify -c "$frpc_config"
      '';

      launchd.daemons.frpc = {
        command = lib.escapeShellArgs [
          (lib.getExe' cfg.package "frpc")
          "-c"
          effectiveConfigFile
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
    })

    # Linux (NixOS systemd) implementation
    (lib.optionalAttrs isLinux {
      environment.systemPackages = [cfg.package];

      systemd.services.frpc = {
        description = "frp client system service";
        after = ["network.target" "network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          ExecStartPre = [
            (pkgs.writeShellScript "frpc-pre-start" ''
              frpc_config=${lib.escapeShellArg effectiveConfigFile}

              if [[ ! -f "$frpc_config" ]]; then
                echo "error: addon.frpc config file is not a regular file: $frpc_config" >&2
                exit 1
              fi

              if [[ ! -r "$frpc_config" ]]; then
                echo "error: addon.frpc config file is not readable by root: $frpc_config" >&2
                exit 1
              fi

              frpc_owner=$(stat -c '%U' "$frpc_config")
              if [[ "$frpc_owner" != "root" ]]; then
                echo "error: addon.frpc config file must be owned by root: $frpc_config" >&2
                exit 1
              fi

              frpc_mode=$(stat -c '%a' "$frpc_config")
              if [[ "$frpc_mode" != "400" && "$frpc_mode" != "600" ]]; then
                echo "error: addon.frpc config file must have mode 0400 or 0600: $frpc_config" >&2
                exit 1
              fi

              ${lib.getExe' cfg.package "frpc"} verify -c "$frpc_config"
            '')
          ];
          ExecStart = "${lib.getExe' cfg.package "frpc"} -c ${lib.escapeShellArg effectiveConfigFile}";
          Restart = "on-failure";
        };
      };
    })
  ]);
}
