{
  config,
  pkgs,
  host,
  username,
  ...
}: {
  sops.secrets."rclone-config" = {
    sopsFile = ./rclone.ini;
    format = "ini";
    key = "";
    owner = username;
    mode = "0400";
  };
}
