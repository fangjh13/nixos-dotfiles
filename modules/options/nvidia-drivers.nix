# https://wiki.nixos.org/wiki/NVIDIA
{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.drivers.nvidiagpu;
in {
  options.drivers.nvidiagpu = {
    enable = mkEnableOption "Enable Nvidia Graphics Drivers";
  };

  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
    };

    hardware.nvidia = {
      open = true;

      # Wayland requires kernel mode setting (KMS) to be enabled
      modesetting.enable = true;

      package = config.boot.kernelPackages.nvidiaPackages.stable; # Default
      # package = config.boot.kernelPackages.nvidiaPackages.beta;
      # package = config.boot.kernelPackages.nvidiaPackages.production;

      # Hybrid graphics with PRIME
      # prime = {
      #   #iGPU
      #   intelBusId = "PCI:0@0:2:0";
      #   # dGPU
      #   nvidiaBusId = "PCI:2@0:0:0";
      #   # amdgpuBusId = "PCI:5@0:0:0"; # If you have an AMD iGPU
      #
      #   # Offload mode
      #   offload = {
      #     enable = true;
      #     # nvidia-offload command
      #     enableOffloadCmd = true;
      #   };
      # };
    };

    # For offloading, `modesetting` is needed additionally,
    # otherwise the X-server will be running permanently on nvidia,
    # thus keeping the GPU always on (see `nvidia-smi`).
    services.xserver.videoDrivers = [
      # "modesetting" # example for Intel iGPU; use "amdgpu" here instead if your iGPU is AMD
      "nvidia"
    ];
  };
}
