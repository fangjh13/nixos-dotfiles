{
  config,
  hostContext,
  lib,
  ...
}: {
  sops.secrets."frpc-config" = {
    sopsFile = ./frpc.toml;
    format = "binary";
    owner = "root";
    group = "wheel";
    mode = "0400";
  };

  sops.secrets."wg-pmind-mac.conf" = {
    sopsFile = ./wg-pmind-mac.conf;
    format = "ini";
    key = "";
    owner = hostContext.username;
    mode = "0400";
  };

  # Run after sops-nix (order 1500) and export a regular file for WireGuard.
  system.activationScripts.postActivation.text = lib.mkOrder 1600 ''
    (
      set -eu
      wireguard_config=${lib.escapeShellArg "/Users/${hostContext.username}/.config/wg-pmind-mac.conf"}
      wireguard_config_dir=$(/usr/bin/dirname "$wireguard_config")

      if [ ! -d "$wireguard_config_dir" ]; then
        /usr/bin/install -d -m 0700 -o ${lib.escapeShellArg hostContext.username} -g staff "$wireguard_config_dir"
      fi

      wireguard_temp=$(/usr/bin/mktemp "$wireguard_config.XXXXXX")
      trap '/bin/rm -f "$wireguard_temp"' EXIT
      /usr/bin/install -m 0400 -o ${lib.escapeShellArg hostContext.username} -g staff \
        ${lib.escapeShellArg config.sops.secrets."wg-pmind-mac.conf".path} "$wireguard_temp"
      /bin/mv -f "$wireguard_temp" "$wireguard_config"
    )
  '';
}
