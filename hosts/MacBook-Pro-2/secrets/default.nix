{
  sops.secrets."frpc-config" = {
    sopsFile = ./frpc.toml;
    format = "binary";
    owner = "root";
    group = "wheel";
    mode = "0400";
  };
}
