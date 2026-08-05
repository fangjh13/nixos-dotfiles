# This module runs Mihomo as a root LaunchDaemon on macOS. Root privileges are
# required for TUN interface creation and transparent proxy route management.
# The service is disabled by default. Keep the complete Mihomo YAML document as
# a shared whole-file sops-nix binary secret so its formatting survives
# encryption. Hosts opt in by importing its declaration module:
#
#   imports = [
#     ../../modules/public/secrets/proxy-clients
#   ];
#
#   addon.mihomo = {
#     enable = true;
#     configFile = config.sops.secrets."mihomo-config".path;
#   };
#
# Keep the plaintext configuration outside this repository. To create or
# replace the encrypted secret atomically from the maintained plaintext:
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
# After changing age or PGP recipients in .sops.yaml, rewrap the existing data
# key without changing the Mihomo plaintext:
#
#   sops updatekeys --input-type binary \
#     modules/public/secrets/proxy-clients/mihomo.yaml
#
# To enable or disable Mihomo, change `addon.mihomo.enable` in the host
# configuration and activate it. Activation materializes the sops-nix secret,
# validates its ownership, mode, and syntax, then lets nix-darwin update the
# LaunchDaemon:
#
#   sudo darwin-rebuild switch \
#     --flake '<flake>?submodules=1#<host>'
#
# This module does not implement hot reload. After replacing the encrypted
# configuration, run the checks above, switch the system, and force a clean
# restart so the running process consumes the new plaintext:
#
#   sudo launchctl kickstart -k system/org.nixos.mihomo
#
# Restore the previous encrypted secret and repeat switch plus kickstart to
# roll back a bad runtime change. Never commit a decrypted configuration.
#
# Runtime paths:
#   Config: /run/secrets/mihomo-config (root-owned, mode 0400 by default)
#   State:  /var/lib/mihomo (root:wheel, mode 0700)
#   Logs:   /var/log/mihomo.log (root:wheel, mode 0600)
#
# Common operations:
#   sudo launchctl print system/org.nixos.mihomo
#   sudo launchctl blame system/org.nixos.mihomo
#   sudo launchctl kickstart -k system/org.nixos.mihomo
#   sudo launchctl bootout system/org.nixos.mihomo
#   sudo tail -F /var/log/mihomo.log
#
# `bootout` stops the currently loaded job only. If the module remains enabled,
# a later nix-darwin switch may load it again. Set `addon.mihomo.enable =
# false` and switch when the service must remain disabled.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.addon.mihomo;
  stateDir = "/var/lib/mihomo";
  logFile = "/var/log/mihomo.log";
  # Keep interpolation type-safe; assertions reject null when the service is
  # enabled.
  configFile =
    if cfg.configFile == null
    then "/dev/null"
    else cfg.configFile;
in {
  options.addon.mihomo = {
    enable = lib.mkEnableOption "Mihomo system service";

    package = lib.mkPackageOption pkgs "mihomo" {};

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/Library/Application Support/mihomo/config.yaml";
      description = ''
        Absolute path to the external Mihomo configuration file. The file
        contents are not copied into the Nix store.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.configFile != null;
        message = "addon.mihomo.configFile must be set when addon.mihomo.enable is true.";
      }
      {
        assertion = cfg.configFile == null || lib.hasPrefix "/" cfg.configFile;
        message = "addon.mihomo.configFile must be an absolute path.";
      }
    ];

    environment.systemPackages = [cfg.package];

    # Prepare private runtime paths and reject missing, unsafe, or invalid
    # configuration before launchd is updated.
    system.activationScripts.extraActivation.text = lib.mkAfter ''
      mihomo_config=${lib.escapeShellArg configFile}
      mihomo_state_dir=${lib.escapeShellArg stateDir}
      mihomo_log_file=${lib.escapeShellArg logFile}

      /usr/bin/install -d -m 0700 -o root -g wheel "$mihomo_state_dir"
      : > "$mihomo_log_file"
      /usr/sbin/chown root:wheel "$mihomo_log_file"
      /bin/chmod 0600 "$mihomo_log_file"

      if [[ ! -f "$mihomo_config" ]]; then
        echo "error: addon.mihomo.configFile is not a regular file: $mihomo_config" >&2
        exit 1
      fi

      if [[ ! -r "$mihomo_config" ]]; then
        echo "error: addon.mihomo.configFile is not readable by root: $mihomo_config" >&2
        exit 1
      fi

      mihomo_owner=$(/usr/bin/stat -f '%Su' "$mihomo_config")
      if [[ "$mihomo_owner" != "root" ]]; then
        echo "error: addon.mihomo.configFile must be owned by root: $mihomo_config" >&2
        exit 1
      fi

      mihomo_mode=$(/usr/bin/stat -f '%Lp' "$mihomo_config")
      if [[ "$mihomo_mode" != "400" && "$mihomo_mode" != "600" ]]; then
        echo "error: addon.mihomo.configFile must have mode 0400 or 0600: $mihomo_config" >&2
        exit 1
      fi

      # Keep validation state separate from the running daemon's cache DB.
      mihomo_validation_dir=$(/usr/bin/mktemp -d /tmp/mihomo-validation.XXXXXX)
      cleanup_mihomo_validation_dir() {
        case "$mihomo_validation_dir" in
          /tmp/mihomo-validation.*)
            /bin/rm -rf "$mihomo_validation_dir"
            ;;
          *)
            echo "error: refusing to remove unexpected Mihomo validation directory: $mihomo_validation_dir" >&2
            return 1
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

    # TUN and route management require root; launchd retries only unsuccessful
    # exits so an intentional clean exit does not create a restart loop.
    launchd.daemons.mihomo = {
      command = lib.escapeShellArgs [
        (lib.getExe cfg.package)
        "-d"
        stateDir
        "-f"
        configFile
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
  };
}
