{
  hostContext,
  ...
}: {
  sops.secrets."rclone-config" = {
    sopsFile = ./rclone.ini;
    format = "ini";
    key = "";
    owner = hostContext.username;
    mode = "0400";
  };
}
