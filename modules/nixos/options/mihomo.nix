# This module runs Mihomo as a systemd service on NixOS.
# The service is disabled by default. You can enable it in a host configuration:
#
#   addon.mihomo.enable = true;
#
# By default, it looks for configuration at `/var/lib/private/mihomo/config.yaml`.
#
# Alternatively, you can manage the configuration via sops-nix by importing the proxy-clients secrets module:
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
#   trap 'rm -f "$mihomo_encrypted_tmp"' EXIT
#   sops encrypt \
#     --filename-override "$mihomo_secret" \
#     --input-type binary \
#     --output-type binary \
#     --output "$mihomo_encrypted_tmp" \
#     <plaintext-config>
#   mv "$mihomo_encrypted_tmp" "$mihomo_secret"
#   trap - EXIT
#
# After changing age or PGP recipients in .sops.yaml, rewrap the existing data
# key without changing the Mihomo plaintext:
#
#   sops updatekeys --input-type binary \
#     modules/public/secrets/proxy-clients/mihomo.yaml
#
# Runtime paths:
#   Config: /run/secrets/mihomo-config or /var/lib/private/mihomo/config.yaml
#   State:  /var/lib/private/mihomo
#
# Common operations:
#   sudo systemctl status mihomo
#   sudo systemctl restart mihomo
#   sudo journalctl -u mihomo -f
{
  config,
  lib,
  pkgs-unstable,
  ...
}: let
  cfg = config.addon.mihomo;
in {
  options.addon.mihomo = {
    enable = lib.mkEnableOption "Mihomo system service";

    package = lib.mkPackageOption pkgs-unstable "mihomo" {};

    configFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/private/mihomo/config.yaml";
      example = "/run/secrets/mihomo-config";
      description = "Absolute path to the external Mihomo configuration file.";
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

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/" cfg.configFile;
        message = "addon.mihomo.configFile must be an absolute path.";
      }
    ];

    services.mihomo = {
      enable = true;
      package = cfg.package;
      configFile = cfg.configFile;
      tunMode = cfg.tunMode;
      processesInfo = cfg.processesInfo;
    };
  };
}
