{ lib, config, pkgs, ... }:
with lib;
let cfg = config.filesystem.nfs;
in {
  options.filesystem.nfs = { enable = mkEnableOption "Enable NFS filesystem"; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ nfs-utils ];
    boot.initrd = {
      supportedFilesystems = [ "nfs" ];
      kernelModules = [ "nfs" ];
    };
  };
}

