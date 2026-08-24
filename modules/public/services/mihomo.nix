# This module runs Mihomo as a system service (LaunchDaemon on macOS, systemd on NixOS).
# Root privileges are required for TUN interface creation and transparent proxy route management.
# The service is disabled by default.
#
# Usage in host configuration:
#   addon.mihomo.enable = true;
#
# Secret provisioning (sops-nix):
# Keep the complete Mihomo YAML document as a shared binary secret so its formatting survives encryption.
# To create or replace the encrypted secret atomically from maintained plaintext:
#
#   mihomo_secret=modules/public/secrets/proxy-clients/mihomo.yaml
#   mihomo_encrypted_tmp="$(mktemp "${TMPDIR:-/tmp}/mihomo-secret.XXXXXX")"
#   trap '/bin/rm -f "$mihomo_encrypted_tmp"' EXIT
#   sops encrypt \
#     --filename-override "$mihomo_secret" \
#     --input-type binary \
#     --output-type binary \
#     --output "$mihomo_encrypted_tmp" \
#     <plaintext-config>
#   /bin/mv "$mihomo_encrypted_tmp" "$mihomo_secret"
#   trap - EXIT
#
# After changing age or PGP recipients in .sops.yaml, rewrap the existing data key:
#
#   sops updatekeys --input-type binary modules/public/secrets/proxy-clients/mihomo.yaml
#
# Runtime paths:
#   Config: /run/secrets/mihomo-config (root-owned, mode 0400 by default)
#   State:  /var/lib/mihomo (mode 0700)
#   Logs:   /var/log/mihomo.log (macOS) / journalctl (NixOS)
#
# Common operations (macOS):
#   sudo launchctl print system/org.nixos.mihomo
#   sudo launchctl blame system/org.nixos.mihomo
#   sudo launchctl kickstart -k system/org.nixos.mihomo
#   sudo launchctl bootout system/org.nixos.mihomo
#   sudo tail -F /var/log/mihomo.log
#
# Common operations (NixOS):
#   sudo systemctl status mihomo
#   sudo systemctl restart mihomo
#   sudo journalctl -u mihomo -f
{
  config,
  lib,
  pkgs,
  hostContext,
  packageSets,
  ...
}: let
  cfg = config.addon.mihomo;
  isLinux = hostContext.platform == "linux";
  isDarwin = !isLinux;

  stateDir = "/var/lib/mihomo";
  logFile = "/var/log/mihomo.log";

  effectiveConfigFile =
    if cfg.configFile != null
    then cfg.configFile
    else "/dev/null";
in {
  options.addon.mihomo = {
    enable = lib.mkEnableOption "Mihomo system service";

    package = lib.mkOption {
      type = lib.types.package;
      default = packageSets.unstable.mihomo;
      description = "The Mihomo package to use.";
    };

    useSopsSecret = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically declare and bind to sops secret configuration.";
    };

    secretName = lib.mkOption {
      type = lib.types.str;
      default = "mihomo-config";
      description = "Name of the sops secret to bind when useSopsSecret is true.";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default =
        if cfg.useSopsSecret
        then config.sops.secrets."${cfg.secretName}".path
        else null;
      defaultText = lib.literalExpression ''if config.addon.mihomo.useSopsSecret then config.sops.secrets.''${config.addon.mihomo.secretName}.path else null'';
      example = "/etc/mihomo/config.yaml";
      description = "Absolute path to Mihomo config file. Overrides sops secret when set.";
    };

    tunMode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable TUN mode for transparent proxying.";
    };

    processesInfo = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable capabilities required for PROCESS-NAME and PROCESS-PATH rules.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.configFile != null;
          message = "addon.mihomo requires configFile to be set (or useSopsSecret = true).";
        }
        {
          assertion = effectiveConfigFile != "/dev/null" && lib.hasPrefix "/" effectiveConfigFile;
          message = "addon.mihomo effective config file path must be an absolute path.";
        }
      ];

      # Lazy secret provisioning
      sops.secrets = lib.optionalAttrs cfg.useSopsSecret {
        "${cfg.secretName}" = {
          sopsFile = ../secrets/proxy-clients/mihomo.yaml;
          format = "binary";
          owner = "root";
          mode = "0400";
        };
      };
    }

    # Darwin (macOS launchd) implementation
    (lib.optionalAttrs isDarwin {
      environment.systemPackages = [cfg.package];

      system.activationScripts.extraActivation.text = lib.mkAfter ''
        mihomo_config=${lib.escapeShellArg effectiveConfigFile}
        mihomo_state_dir=${lib.escapeShellArg stateDir}
        mihomo_log_file=${lib.escapeShellArg logFile}

        /usr/bin/install -d -m 0700 -o root -g wheel "$mihomo_state_dir"
        : > "$mihomo_log_file"
        /usr/sbin/chown root:wheel "$mihomo_log_file"
        /bin/chmod 0600 "$mihomo_log_file"

        if [[ ! -f "$mihomo_config" ]]; then
          echo "error: addon.mihomo config file is not a regular file: $mihomo_config" >&2
          exit 1
        fi

        if [[ ! -r "$mihomo_config" ]]; then
          echo "error: addon.mihomo config file is not readable by root: $mihomo_config" >&2
          exit 1
        fi

        mihomo_owner=$(/usr/bin/stat -f '%Su' "$mihomo_config")
        if [[ "$mihomo_owner" != "root" ]]; then
          echo "error: addon.mihomo config file must be owned by root: $mihomo_config" >&2
          exit 1
        fi

        mihomo_mode=$(/usr/bin/stat -f '%Lp' "$mihomo_config")
        if [[ "$mihomo_mode" != "400" && "$mihomo_mode" != "600" ]]; then
          echo "error: addon.mihomo config file must have mode 0400 or 0600: $mihomo_config" >&2
          exit 1
        fi

        mihomo_validation_dir=$(/usr/bin/mktemp -d /tmp/mihomo-validation.XXXXXX)
        cleanup_mihomo_validation_dir() {
          case "$mihomo_validation_dir" in
            /tmp/mihomo-validation.*)
              /bin/rm -rf "$mihomo_validation_dir"
              ;;
          esac
        }
        trap cleanup_mihomo_validation_dir EXIT

        ${lib.getExe cfg.package} \
          -d "$mihomo_validation_dir" \
          -f "$mihomo_config" \
          -t

        cleanup_mihomo_validation_dir
        trap - EXIT
      '';

      launchd.daemons.mihomo = {
        command = lib.escapeShellArgs [
          (lib.getExe cfg.package)
          "-d"
          stateDir
          "-f"
          effectiveConfigFile
        ];

        serviceConfig = {
          UserName = "root";
          GroupName = "wheel";
          RunAtLoad = true;
          KeepAlive = {
            SuccessfulExit = false;
          };
          StandardOutPath = logFile;
          StandardErrorPath = logFile;
          Umask = 63;
        };
      };
    })

    # Linux (NixOS systemd) implementation
    (lib.optionalAttrs isLinux {
      services.mihomo = {
        enable = true;
        package = cfg.package;
        configFile = effectiveConfigFile;
        tunMode = cfg.tunMode;
        processesInfo = cfg.processesInfo;
      };

      systemd.services.mihomo.serviceConfig.ExecStartPre = [
        (pkgs.writeShellScript "mihomo-pre-start" ''
          # NixOS services.mihomo uses DynamicUser = true and LoadCredential to supply
          # secrets safely. Prefer CREDENTIALS_DIRECTORY over root-only /run/secrets.
          mihomo_config="''${CREDENTIALS_DIRECTORY:-}/config.yaml"
          if [[ ! -f "$mihomo_config" ]]; then
            mihomo_config=${lib.escapeShellArg effectiveConfigFile}
          fi

          if [[ ! -f "$mihomo_config" ]]; then
            echo "error: addon.mihomo config file is not a regular file: $mihomo_config" >&2
            exit 1
          fi

          if [[ ! -r "$mihomo_config" ]]; then
            echo "error: addon.mihomo config file is not readable: $mihomo_config" >&2
            exit 1
          fi

          # Pass a temporary working directory to prevent mihomo -t from trying to create
          # /.config/mihomo on systemd's read-only root filesystem.
          mihomo_validation_dir=$(mktemp -d /tmp/mihomo-validation.XXXXXX)
          cleanup_validation_dir() {
            rm -rf "$mihomo_validation_dir"
          }
          trap cleanup_validation_dir EXIT

          ${lib.getExe cfg.package} -t -d "$mihomo_validation_dir" -f "$mihomo_config"
        '')
      ];
    })
  ]);
}
