{pkgs, ...}: {
  # Enable Hypridle, Hyprland's idle daemon.
  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms(\"on\")'";
          before_sleep_cmd = "loginctl lock-session; sleep 1";
          lock_cmd = "screenlock";
          ignore_dbus_inhibit = false;
          ignore_systemd_inhibit = false;
        };
        listener = [
          # Screenlock
          {
            timeout = 305;
            on-timeout = "screenlock";
          }
          # dpms
          {
            timeout = 300;
            on-timeout = "hyprctl dispatch 'hl.dsp.dpms(\"off\")'";
            on-resume = "hyprctl dispatch 'hl.dsp.dpms(\"on\")'";
          }
          # Suspend
          # {
          #   timeout = 1800;
          #   on-timeout = "systemctl suspend";
          # }
        ];
      };
    };
  };
}
