{ pkgs, username, ... }: {

  environment.systemPackages = with pkgs; [
  greetd.tuigreet
  # thunar need for image preview (https://gitlab.xfce.org/xfce/thunar/-/issues/1285)
  xfce.xfconf
  # LXQt PolicyKit agent
  lxqt.lxqt-policykit
  # GNOME network-manager-aplet
  networkmanagerapplet
  ];

  services = {
    xserver = { enable = false; };
    greetd = {
      enable = true;
      # The virtual console (tty) that greetd should use
      vt = 3;
      settings = {
        default_session = {
          # Wayland Desktop Manager is installed only for user ${username} via home-manager
          user = "${username}";
          # Start Hyprland with a TUI login manager
          command =
            "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        };
      };
    };
  };

  # Extra Portal Configuration
  xdg.portal = {
    enable = true;
    # enable desktop portal for wlroots-based desktops.
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal
    ];
  };

  # thunar file manager (part of xfce)
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-volman # automatic management of removable drives and media
      thunar-archive-plugin # providing file context menus for archives
      thunar-media-tags-plugin # providing tagging and renaming features for media files
    ];
  };

  # Tumbler, A D-Bus thumbnailer service
  services.tumbler.enable = true;
  # Manage users security credentials, such as user names and passwords
  services.gnome.gnome-keyring.enable = true;
  # a GNOME application for managing encryption keys and passwords in the GNOME Keyring
  programs.seahorse.enable = true;
  # Enables GnuPG agent with socket-activation for every user session.
  programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

}
