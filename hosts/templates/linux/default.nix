{hostContext, ...}: {
  imports = [./hardware-configuration.nix];

  home-manager.users.${hostContext.username}.imports = [./home.nix];

  time.timeZone = "%%TIMEZONE%%";

  profiles.desktop = {
    enable = true;
    defaultTerminal = "kitty";
    hyprland = {
      monitors = [
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1.0;
        }
      ];
      xkbOptions = ["ctrl:nocaps" "altwin:swap_lalt_lwin"];
    };
  };

  # Keep firewall policy explicit for every Host.
  networking.firewall.enable = false;

  # Keep the installation compatibility version explicit and stable.
  system.stateVersion = "25.05";
}
