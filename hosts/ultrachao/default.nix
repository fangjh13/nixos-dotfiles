{hostContext, ...}: {
  imports = [./hardware-configuration.nix];

  home-manager.users.${hostContext.username}.imports = [./home.nix];

  time.timeZone = "Asia/Singapore";

  profiles.desktop = {
    enable = true;
    defaultTerminal = "kitty";
    hyprland = {
      monitors = [
        {
          output = "";
          mode = "3840x2160@60";
          position = "auto";
          scale = 2.0;
        }
      ];
      xkbOptions = ["ctrl:nocaps"];
      sessionVariables = {
        AQ_DRM_DEVICES = "/dev/dri/nvidia-dgpu:/dev/dri/intel-igpu";
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        NVD_BACKEND = "direct";
      };
    };
  };

  drivers.intel.enable = true;
  drivers.nvidiagpu.enable = true;

  services.udev.extraRules = ''
    KERNEL=="card*", KERNELS=="0000:00:02.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/intel-igpu"
    KERNEL=="card*", KERNELS=="0000:02:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/nvidia-dgpu"
  '';

  networking.firewall.enable = false;

  system.stateVersion = "25.05";
}
