# Scheduled local-to-cloud uploads with rclone.
#
# What this module does:
# - Installs rclone when `addon.rclone.enable` is true.
# - Creates one systemd service and timer for every entry in
#   `addon.rclone.jobs`.
# - Uses `rclone copy`, so files that only exist at the destination are never
#   deleted. Changed files may still be replaced by newer local versions.
# - Runs each service as the main non-root user, even when that user is not
#   logged in.
#
# Example host configuration:
#
#   addon.rclone = {
#     enable = true;
#     jobs.documents = {
#       source = "/home/fython/Documents";
#       destination = "cloud:backup/my-host/documents";
#       onCalendar = "*-*-* 03:00:00";
#       extraArgs = [ "--exclude" "*.tmp" ];
#     };
#   };
#
# Supply an explicit configuration path when credentials are managed outside
# the user's home directory. For the sops-nix pattern used by this repository,
# configure `mutableConfig` with the decrypted secret as its seed; this gives
# rclone a writable state file for OAuth token refreshes. See docs/secrets.md.
# Never put credentials in Nix strings. Validate a
# configuration as the normal user before enabling a job:
#
#   rclone --config /path/to/rclone.conf listremotes
#   rclone --config /path/to/rclone.conf \
#     copy /path/to/source cloud:backup/path --dry-run -v
#
# The generated units are named `rclone-copy-<job>.service` and
# `rclone-copy-<job>.timer`. Inspect them with:
#
#   systemctl status rclone-copy-<job>.service
#   systemctl list-timers 'rclone-copy-*'
#   journalctl -u rclone-copy-<job>.service
{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.addon.rclone;
  homeDirectory = config.users.users.${username}.home;
  primaryGroup = config.users.users.${username}.group;
  unitName = name: "rclone-copy-${name}";
  configUnit = "rclone-config.service";
  mutableConfig = cfg.mutableConfig;
  stateDirectory = "rclone";
  mutableConfigPath = "/var/lib/${stateDirectory}/rclone.conf";
  effectiveConfigFile =
    if mutableConfig != null
    then mutableConfigPath
    else if cfg.configFile != null
    then cfg.configFile
    else "${homeDirectory}/.config/rclone/rclone.conf";

  jobType = lib.types.submodule {
    options = {
      source = lib.mkOption {
        type = lib.types.str;
        example = "/home/alice/Documents";
        description = "Absolute path to the local directory to upload.";
      };

      destination = lib.mkOption {
        type = lib.types.str;
        example = "cloud:backup/host/documents";
        description = "Rclone destination in remote:path format.";
      };

      onCalendar = lib.mkOption {
        type = lib.types.str;
        default = "*-*-* 03:00:00";
        description = "systemd OnCalendar expression for the upload timer.";
      };

      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["--exclude" "*.tmp"];
        description = "Additional non-secret arguments passed to rclone copy.";
      };
    };
  };

  mkService = name: job: {
    description = "Upload ${name} with rclone";

    # This is a system service so the job can run without an active login
    # session. The network target provides ordering during boot; rclone still
    # handles transient cloud or connectivity failures itself.
    wants = ["network-online.target"];
    requires = lib.optional (mutableConfig != null) configUnit;
    after =
      ["network-online.target"]
      ++ lib.optional (mutableConfig != null) configUnit;

    # A system service does not inherit the user's login environment. Set the
    # home paths explicitly so rclone uses the same locations as interactive
    # commands run by the user.
    environment = {
      HOME = homeDirectory;
      XDG_CONFIG_HOME = "${homeDirectory}/.config";
    };

    # Fail with a useful journal message instead of letting rclone run with a
    # missing source or silently fall back to another configuration file.
    preStart = ''
      source_path=${lib.escapeShellArg job.source}
      config_file=${lib.escapeShellArg effectiveConfigFile}

      if [[ ! -d "$source_path" ]]; then
        echo "rclone source directory does not exist: $source_path" >&2
        exit 1
      fi

      if [[ ! -r "$config_file" ]]; then
        echo "rclone config file is not readable: $config_file" >&2
        exit 1
      fi
    '';

    # `escapeShellArgs` keeps paths and additional arguments as separate shell
    # arguments, including values that contain spaces or wildcard characters.
    script = ''
      exec ${lib.escapeShellArgs (
        [
          (lib.getExe pkgs.rclone)
          "copy"
          "--config"
          effectiveConfigFile
          "--log-level"
          "INFO"
        ]
        ++ job.extraArgs
        ++ [
          job.source
          job.destination
        ]
      )}
    '';

    serviceConfig = {
      Type = "oneshot";
      User = username;
      UMask = "0077";
    };
  };

  mutableConfigService = {
    description = "Prepare writable rclone configuration";
    wantedBy = ["multi-user.target"];
    before = map (name: "${unitName name}.service") (builtins.attrNames cfg.jobs);
    requires = lib.optional config.sops.useSystemdActivation "sops-install-secrets.service";
    after = lib.optional config.sops.useSystemdActivation "sops-install-secrets.service";

    # Re-run the initializer when the encrypted seed changes. The marker in
    # the state directory prevents ordinary boots or rebuilds from replacing
    # OAuth tokens that rclone refreshed in the writable runtime file.
    restartTriggers = [mutableConfig.seedVersion];

    script = let
      configFile = mutableConfigPath;
      versionFile = "/var/lib/${stateDirectory}/.seed-version";
    in ''
      seed_file=${lib.escapeShellArg mutableConfig.seedFile}
      seed_version=${lib.escapeShellArg mutableConfig.seedVersion}
      config_file=${lib.escapeShellArg configFile}
      version_file=${lib.escapeShellArg versionFile}
      installed_version=

      if [[ ! -r "$seed_file" ]]; then
        echo "rclone seed configuration is not readable: $seed_file" >&2
        exit 1
      fi

      if [[ -r "$version_file" ]]; then
        IFS= read -r installed_version < "$version_file" || true
      fi

      if [[ -f "$config_file" && "$installed_version" == "$seed_version" ]]; then
        exit 0
      fi

      config_temp="$(${lib.getExe' pkgs.coreutils "mktemp"} "$config_file.tmp.XXXXXX")"
      version_temp="$(${lib.getExe' pkgs.coreutils "mktemp"} "$version_file.tmp.XXXXXX")"

      cleanup() {
        ${lib.getExe' pkgs.coreutils "rm"} -f -- "$config_temp" "$version_temp"
      }
      trap cleanup EXIT

      ${lib.getExe' pkgs.coreutils "install"} -m 0600 "$seed_file" "$config_temp"
      printf '%s\n' "$seed_version" > "$version_temp"
      ${lib.getExe' pkgs.coreutils "chmod"} 0600 "$version_temp"
      ${lib.getExe' pkgs.coreutils "mv"} -f -- "$config_temp" "$config_file"
      ${lib.getExe' pkgs.coreutils "mv"} -f -- "$version_temp" "$version_file"

      trap - EXIT
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = username;
      Group = primaryGroup;
      UMask = "0077";
      StateDirectory = stateDirectory;
      StateDirectoryMode = "0700";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
    };
  };

  mkTimer = name: job: {
    description = "Timer for ${unitName name}";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = job.onCalendar;

      # Run a missed calendar event after the machine starts again. A small
      # random delay avoids every configured job starting at exactly 03:00.
      Persistent = true;
      RandomizedDelaySec = "15m";
      Unit = "${unitName name}.service";
    };
  };
in {
  options.addon.rclone = {
    # This is the host-level switch. Disabled hosts install no rclone package
    # and generate no rclone services or timers.
    enable = lib.mkEnableOption "scheduled rclone uploads";

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional absolute path to a static rclone configuration file.";
    };

    mutableConfig = lib.mkOption {
      type = lib.types.nullOr (lib.types.submodule {
        options = {
          seedFile = lib.mkOption {
            type = lib.types.str;
            example = "/run/secrets/rclone-config";
            description = "Read-only seed copied into the writable rclone state file.";
          };

          seedVersion = lib.mkOption {
            type = lib.types.str;
            example = "sha256 hash supplied by sops.secrets.<name>.sopsFileHash";
            description = "Non-secret version identifier used to detect seed changes.";
          };

        };
      });
      default = null;
      description = ''
        Optional read-only seed for a writable rclone configuration. This is
        required for SOPS-managed OAuth configurations because rclone writes
        refreshed tokens back to its configuration file.
      '';
    };

    jobs = lib.mkOption {
      type = lib.types.attrsOf jobType;
      default = {};
      # Each attribute name becomes part of a systemd unit name, which is why
      # the assertions below restrict job names to safe characters.
      description = "Named local-to-remote rclone copy jobs.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      [
        {
          assertion = cfg.jobs != {};
          message = "addon.rclone.enable requires at least one addon.rclone.jobs entry.";
        }
        {
          assertion = cfg.configFile == null || lib.hasPrefix "/" cfg.configFile;
          message = "addon.rclone.configFile must be an absolute path.";
        }
      ]
      ++ lib.optionals (mutableConfig != null) [
        {
          assertion = cfg.configFile == null;
          message = "addon.rclone.configFile and addon.rclone.mutableConfig cannot be used together.";
        }
        {
          assertion = lib.hasPrefix "/" mutableConfig.seedFile;
          message = "addon.rclone.mutableConfig.seedFile must be an absolute path.";
        }
        {
          assertion = mutableConfig.seedVersion != "";
          message = "addon.rclone.mutableConfig.seedVersion must not be empty.";
        }
      ]
      ++ lib.concatLists (lib.mapAttrsToList (name: job: [
          {
            assertion = builtins.match "^[A-Za-z0-9_-]+$" name != null;
            message = "addon.rclone job name '${name}' may only contain letters, numbers, underscores, and hyphens.";
          }
          {
            assertion = lib.hasPrefix "/" job.source;
            message = "addon.rclone.jobs.${name}.source must be an absolute path.";
          }
          {
            assertion = job.destination != "";
            message = "addon.rclone.jobs.${name}.destination must not be empty.";
          }
          {
            assertion = job.onCalendar != "";
            message = "addon.rclone.jobs.${name}.onCalendar must not be empty.";
          }
        ])
        cfg.jobs);

    environment.systemPackages = [pkgs.rclone];

    # The attribute-set mapping creates an independent service and timer for
    # every job, allowing different source paths, destinations, and schedules.
    systemd.services =
      lib.optionalAttrs (mutableConfig != null) {
        rclone-config = mutableConfigService;
      }
      // lib.mapAttrs' (
        name: job: lib.nameValuePair (unitName name) (mkService name job)
      )
      cfg.jobs;

    systemd.timers =
      lib.mapAttrs' (
        name: job: lib.nameValuePair (unitName name) (mkTimer name job)
      )
      cfg.jobs;
  };
}
