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
      #  true: open-source modules, false: proprietary modules
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

    # VA-API hardware video acceleration
    # https://wiki.hypr.land/Nvidia/#va-api-hardware-video-acceleration
    # https://discourse.nixos.org/t/nvidia-open-breaks-hardware-acceleration/58770/2
    hardware.opengl.extraPackages = [
      pkgs.nvidia-vaapi-driver
    ];
    environment.variables = {
      NVD_BACKEND = "direct";
      LIBVA_DRIVER_NAME = "nvidia";
    };
  };
}
