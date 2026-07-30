{
  sops.secrets."sing-box-config" = {
    sopsFile = ./sing-box.jsonc;
    format = "binary";
    owner = "root";
    mode = "0400";
  };

  sops.secrets."mihomo-config" = {
    sopsFile = ./mihomo.yaml;
    format = "binary";
    owner = "root";
    mode = "0400";
  };
}
