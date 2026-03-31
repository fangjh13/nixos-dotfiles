{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Graphical console greeter for greetd.
    tuigreet
    # thunar need for image preview (https://gitlab.xfce.org/xfce/thunar/-/issues/1285)
    xfconf
    # LXQt PolicyKit agent
    lxqt.lxqt-policykit
    # GNOME network-manager-aplet
    networkmanagerapplet
    # An archive manager utility
    kdePackages.ark
  ];

  services = {
    xserver = {enable = false;};
    greetd = {
      enable = true;
      settings = {
        default_session = {
          # Wayland Desktop Manager is installed only for user ${username} via home-manager
          user = "${username}";
          # Start Hyprland with a TUI login manager
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
        };
      };
    };
  };

  # Portal Configuration
  xdg.portal = {
    enable = true;

    # Fallback to GTK portal for applications that do not support the Hyprland portal
    extraPortals = [pkgs.xdg-desktop-portal-gtk];

    config = {
      # If in the hyprland environment:
      # - Prefer the hyprland portal (for handling screen sharing, etc.)
      # - If the hyprland portal cannot handle it (like file selection dialogs), fall back
      hyprland = {
        default = ["hyprland" "gtk"];
      };

      # As a catch-all fallback, any environment that doesn't match the above will default to using the GTK portal
      common = {
        default = ["gtk"];
      };
    };
  };

  environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];

  # thunar file manager (part of xfce)
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-volman # automatic management of removable drives and media
      thunar-archive-plugin # providing file context menus for archives
      thunar-media-tags-plugin # providing tagging and renaming features for media files
    ];
  };

  # Tumbler, A D-Bus thumbnailer service
  services.tumbler.enable = true;
  # Mount, trash, and other functionalities
  services.gvfs.enable = true;
  # Manage users security credentials, such as user names and passwords
  services.gnome.gnome-keyring.enable = true;
  # a GNOME application for managing encryption keys and passwords in the GNOME Keyring
  programs.seahorse.enable = true;
  # Enable dconf to allow Home Manager to configure it
  programs.dconf.enable = true;

  # Enable PAM hyprlock to perform authentication
  security.pam.services.hyprlock = {};
}
