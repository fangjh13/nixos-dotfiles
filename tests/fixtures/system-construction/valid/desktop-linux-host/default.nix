{
  hostContext,
  lib,
  ...
}: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  fileSystems."/" = {
    device = "/dev/null";
    fsType = "ext4";
  };
  time.timeZone = "Etc/UTC";
  profiles.desktop = {
    enable = true;
    defaultTerminal = "wezterm";
    hyprland = {
      monitors = [
        {
          output = "Virtual-1";
          mode = "1920x1080@60";
          position = "auto";
          scale = 1.0;
        }
      ];
      xkbOptions = ["ctrl:nocaps" "altwin:swap_lalt_lwin"];
      sessionVariables.PROFILE_TEST = "enabled";
      extraLua = ''
        hl.env("PROFILE_EXTRA_LUA", "enabled")
      '';
    };
  };
  home-manager.users.${hostContext.username} = {
    imports = [
      ../../../../../modules/public/homemanager/terminals/ghostty
      ../../../../../modules/public/homemanager/terminals/kitty
    ];
    programs = {
      git.settings.user = {
        name = "Desktop User";
        email = "desktop@example.com";
      };
      ghostty.enable = true;
    };
  };
  system.stateVersion = "26.05";
}
