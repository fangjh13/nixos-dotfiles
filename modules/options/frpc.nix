{ pkgs, lib, ... }: {
  environment.systemPackages = [ pkgs.frp ];

  systemd.services."frpc" = {
    description = "frp client";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.frp}/bin/frpc -c /var/lib/private/frp/frpc.toml";
      Restart = "always";
      RestartSec = 5;
      StartLimitBurst = 99;
    };
  };
}
