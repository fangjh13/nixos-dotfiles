# clipboard history manager
{ ... }: {
  services.cliphist = {
    enable = true;
    systemdTarget = "hyprland-session.target";
  };
}
