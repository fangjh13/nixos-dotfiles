# https://wiki.nixos.org/wiki/Intel_Graphics
{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.drivers.intel;
in {
  options.drivers.intel = {
    enable = mkEnableOption "Enable Intel Graphics Drivers";
  };

  config = mkIf cfg.enable {
    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
    };

    # OpenGL
    hardware = {
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vaapiIntel
          libva-vdpau-driver
          libvdpau-va-gl
        ];
      };
      # intel_gpu_top command
      intel-gpu-tools.enable = true;
    };
  };
}
