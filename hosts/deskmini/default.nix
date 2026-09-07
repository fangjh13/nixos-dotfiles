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
      xkbOptions = ["ctrl:nocaps" "altwin:swap_lalt_lwin"];
    };
  };

  drivers.intel.enable = true;
  kernel.zen.enable = true;

  networking.interfaces.eno2.wakeOnLan.enable = true;
  networking.firewall.enable = false;

  system.stateVersion = "25.05";
}
