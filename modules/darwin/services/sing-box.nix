# This module runs sing-box as a root LaunchDaemon on macOS. Root privileges are
# required by configurations that create a TUN interface or manage transparent
# proxy routes. The service is disabled by default; enable it in a Darwin host:
#
#   services.sing-box = {
#     enable = true;
#     configFile = "/Library/Application Support/sing-box/config.json";
#   };
#
# Keep configFile outside the Nix store because it may contain subscription
# URLs, UUIDs, passwords, or private keys. Install it before activating the host:
#
#   sudo install -d -m 0700 -o root -g wheel \
#     '/Library/Application Support/sing-box'
#   sudo install -m 0600 -o root -g wheel /path/to/config.json \
#     '/Library/Application Support/sing-box/config.json'
#
# Activation creates the private runtime paths, checks that the configuration is
# a root-owned regular file with mode 0400 or 0600, and runs `sing-box check`
# before nix-darwin loads or reloads the LaunchDaemon. Only the configuration
# path is embedded in generated Nix artifacts; the file contents stay external.
#
# Runtime paths:
#   State: /var/lib/sing-box
#   Logs:  /var/log/sing-box.log (root:wheel, mode 0600)
#
# Common operations:
#   sudo launchctl print system/org.nixos.sing-box
#   sudo launchctl kickstart -k system/org.nixos.sing-box  # force restart
#   sudo tail -f /var/log/sing-box.log
#
# Validate a changed configuration before asking sing-box to reload it:
#   sudo /run/current-system/sw/bin/sing-box \
#     -D /var/lib/sing-box --disable-color \
#     -c '/Library/Application Support/sing-box/config.json' check
#   sudo launchctl kill SIGHUP system/org.nixos.sing-box
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.sing-box;
  stateDir = "/var/lib/sing-box";
  logFile = "/var/log/sing-box.log";
  # Keep interpolation type-safe; assertions reject null when the service is
  # enabled.
  configFile =
    if cfg.configFile == null
    then "/dev/null"
    else cfg.configFile;
in {
  options.services.sing-box = {
    enable = lib.mkEnableOption "sing-box system service";

    package = lib.mkPackageOption pkgs "sing-box" {};

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/Library/Application Support/sing-box/config.json";
      description = ''
        Absolute path to the external sing-box configuration file. The file
        contents are not copied into the Nix store.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.configFile != null;
        message = "services.sing-box.configFile must be set when services.sing-box.enable is true.";
      }
      {
        assertion = cfg.configFile == null || lib.hasPrefix "/" cfg.configFile;
        message = "services.sing-box.configFile must be an absolute path.";
      }
    ];

    environment.systemPackages = [cfg.package];

    # Reject missing, unsafe, or invalid configuration before launchd is updated.
    system.activationScripts.extraActivation.text = lib.mkAfter ''
      sing_box_config=${lib.escapeShellArg configFile}
      sing_box_state_dir=${lib.escapeShellArg stateDir}
      sing_box_log_file=${lib.escapeShellArg logFile}

      /usr/bin/install -d -m 0700 -o root -g wheel "$sing_box_state_dir"
      /usr/bin/touch "$sing_box_log_file"
      /usr/sbin/chown root:wheel "$sing_box_log_file"
      /bin/chmod 0600 "$sing_box_log_file"

      if [[ ! -f "$sing_box_config" ]]; then
        echo "error: services.sing-box.configFile is not a regular file: $sing_box_config" >&2
        exit 1
      fi

      if [[ ! -r "$sing_box_config" ]]; then
        echo "error: services.sing-box.configFile is not readable by root: $sing_box_config" >&2
        exit 1
      fi

      sing_box_owner=$(/usr/bin/stat -f '%Su' "$sing_box_config")
      if [[ "$sing_box_owner" != "root" ]]; then
        echo "error: services.sing-box.configFile must be owned by root: $sing_box_config" >&2
        exit 1
      fi

      sing_box_mode=$(/usr/bin/stat -f '%Lp' "$sing_box_config")
      if [[ "$sing_box_mode" != "400" && "$sing_box_mode" != "600" ]]; then
        echo "error: services.sing-box.configFile must have mode 0400 or 0600: $sing_box_config" >&2
        exit 1
      fi

      ${lib.getExe cfg.package} \
        -D "$sing_box_state_dir" \
        --disable-color \
        -c "$sing_box_config" \
        check
    '';

    # TUN and route management require root; restart only after unsuccessful
    # exits.
    launchd.daemons.sing-box = {
      command = lib.escapeShellArgs [
        (lib.getExe cfg.package)
        "-D"
        stateDir
        "--disable-color"
        "-c"
        configFile
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
  };
}
