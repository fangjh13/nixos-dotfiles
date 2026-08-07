# This module runs sing-box as a system service (LaunchDaemon on macOS, systemd on NixOS).
# Root privileges are required by configurations that create a TUN interface or manage transparent proxy routes.
# The service is disabled by default.
#
# Usage in host configuration:
#   addon.sing-box.enable = true;
#
# Secret provisioning (sops-nix):
# Encrypt JSONC as an opaque binary document so comments and formatting survive byte-for-byte:
#
#   sops encrypt \
#     --filename-override modules/public/secrets/proxy-clients/sing-box.jsonc \
#     --input-type binary \
#     --output-type binary \
#     --output modules/public/secrets/proxy-clients/sing-box.jsonc.new \
#     /path/to/sing-box.jsonc
#   mv modules/public/secrets/proxy-clients/sing-box.jsonc.new \
#     modules/public/secrets/proxy-clients/sing-box.jsonc
#
# Runtime paths:
#   Config: /run/secrets/sing-box-config (root-owned, mode 0400)
#   State:  /var/lib/sing-box
#   Logs:   /var/log/sing-box.log (macOS) / journalctl (NixOS)
#
# Common operations (macOS):
#   sudo launchctl print system/org.nixos.sing-box
#   sudo launchctl kickstart -k system/org.nixos.sing-box
#   sudo tail -f /var/log/sing-box.log
#
# Common operations (NixOS):
#   sudo systemctl status sing-box
#   sudo systemctl restart sing-box
#   sudo journalctl -u sing-box -f
#
# Validate a changed configuration before reloading:
#   sudo sing-box -D /var/lib/sing-box --disable-color -c /run/secrets/sing-box-config check
{
  config,
  lib,
  pkgs,
  isLinux ? true,
  ...
}: let
  cfg = config.addon.sing-box;
  isDarwin = !isLinux;

  stateDir = "/var/lib/sing-box";
  logFile = "/var/log/sing-box.log";

  effectiveConfigFile =
    if cfg.configFile != null
    then cfg.configFile
    else "/dev/null";
in {
  options.addon.sing-box = {
    enable = lib.mkEnableOption "sing-box system service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.sing-box;
      description = "The sing-box package to use.";
    };

    useSopsSecret = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically declare and bind to sops secret configuration.";
    };

    secretName = lib.mkOption {
      type = lib.types.str;
      default = "sing-box-config";
      description = "Name of the sops secret to bind when useSopsSecret is true.";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = if cfg.useSopsSecret then config.sops.secrets."${cfg.secretName}".path else null;
      defaultText = lib.literalExpression ''if config.addon.sing-box.useSopsSecret then config.sops.secrets.''${config.addon.sing-box.secretName}.path else null'';
      example = "/etc/sing-box/config.json";
      description = "Absolute path to sing-box config file. Overrides sops secret when set.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.configFile != null;
          message = "addon.sing-box requires configFile to be set (or useSopsSecret = true).";
        }
        {
          assertion = effectiveConfigFile != "/dev/null" && lib.hasPrefix "/" effectiveConfigFile;
          message = "addon.sing-box effective config file path must be an absolute path.";
        }
      ];

      # Lazy secret provisioning
      sops.secrets = lib.optionalAttrs cfg.useSopsSecret {
        "${cfg.secretName}" = {
          sopsFile = ../secrets/proxy-clients/sing-box.jsonc;
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
        sing_box_config=${lib.escapeShellArg effectiveConfigFile}
        sing_box_state_dir=${lib.escapeShellArg stateDir}
        sing_box_log_file=${lib.escapeShellArg logFile}

        /usr/bin/install -d -m 0700 -o root -g wheel "$sing_box_state_dir"
        : > "$sing_box_log_file"
        /usr/sbin/chown root:wheel "$sing_box_log_file"
        /bin/chmod 0600 "$sing_box_log_file"

        if [[ ! -f "$sing_box_config" ]]; then
          echo "error: addon.sing-box config file is not a regular file: $sing_box_config" >&2
          exit 1
        fi

        if [[ ! -r "$sing_box_config" ]]; then
          echo "error: addon.sing-box config file is not readable by root: $sing_box_config" >&2
          exit 1
        fi

        sing_box_owner=$(/usr/bin/stat -f '%Su' "$sing_box_config")
        if [[ "$sing_box_owner" != "root" ]]; then
          echo "error: addon.sing-box config file must be owned by root: $sing_box_config" >&2
          exit 1
        fi

        sing_box_mode=$(/usr/bin/stat -f '%Lp' "$sing_box_config")
        if [[ "$sing_box_mode" != "400" && "$sing_box_mode" != "600" ]]; then
          echo "error: addon.sing-box config file must have mode 0400 or 0600: $sing_box_config" >&2
          exit 1
        fi

        ${lib.getExe cfg.package} \
          -D "$sing_box_state_dir" \
          --disable-color \
          -c "$sing_box_config" \
          check
      '';

      launchd.daemons.sing-box = {
        command = lib.escapeShellArgs [
          (lib.getExe cfg.package)
          "-D"
          stateDir
          "--disable-color"
          "-c"
          effectiveConfigFile
          "run"
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
      environment.systemPackages = [cfg.package];

      systemd.services.sing-box = {
        description = "sing-box system service";
        after = ["network.target" "network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          ExecStartPre = [
            (pkgs.writeShellScript "sing-box-pre-start" ''
              sing_box_config=${lib.escapeShellArg effectiveConfigFile}

              if [[ ! -f "$sing_box_config" ]]; then
                echo "error: addon.sing-box config file is not a regular file: $sing_box_config" >&2
                exit 1
              fi

              if [[ ! -r "$sing_box_config" ]]; then
                echo "error: addon.sing-box config file is not readable by root: $sing_box_config" >&2
                exit 1
              fi

              sing_box_owner=$(stat -c '%U' "$sing_box_config")
              if [[ "$sing_box_owner" != "root" ]]; then
                echo "error: addon.sing-box config file must be owned by root: $sing_box_config" >&2
                exit 1
              fi

              sing_box_mode=$(stat -c '%a' "$sing_box_config")
              if [[ "$sing_box_mode" != "400" && "$sing_box_mode" != "600" ]]; then
                echo "error: addon.sing-box config file must have mode 0400 or 0600: $sing_box_config" >&2
                exit 1
              fi

              ${lib.getExe cfg.package} -D ${stateDir} --disable-color -c "$sing_box_config" check
            '')
          ];
          ExecStart = "${lib.getExe cfg.package} -D ${stateDir} --disable-color -c ${lib.escapeShellArg effectiveConfigFile} run";
          Restart = "on-failure";
          StateDirectory = "sing-box";
        };
      };
    })
  ]);
}
