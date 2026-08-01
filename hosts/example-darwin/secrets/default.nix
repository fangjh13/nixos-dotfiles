{
  config,
  pkgs,
  host,
  username,
  ...
}: {
  # Declare host-specific sops secrets here after adding this Mac's public age
  # recipient to .sops.yaml. See docs/secrets.md.

  # sops.secrets."xxx-config" = {
  #   sopsFile = ./config.toml;
  #   format = "binary";
  #   owner = "root";
  #   group = "wheel";
  #   mode = "0400";
  # };
}
