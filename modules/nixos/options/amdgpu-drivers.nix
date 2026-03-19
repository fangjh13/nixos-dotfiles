# https://wiki.nixos.org/wiki/AMD_GPU
{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.drivers.amdgpu;
in {
  options.drivers.amdgpu = {
    enable = mkEnableOption "Enable AMD Graphics Drivers";
  };

  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    systemd.tmpfiles.rules = let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [rocblas hipblas clr];
      };
    in ["L+    /opt/rocm   -    -    -     -    ${rocmEnv}"];

    environment.systemPackages = with pkgs; [amdgpu_top];
  };
}
