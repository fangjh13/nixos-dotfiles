{
  pkgs,
  host,
  ...
}: let
  inherit (import ../../../../../hosts/${host}/variables.nix) bookmarks;
in {
  # GTK+ 2/3 applications themes config
  gtk = {
    enable = true;
    gtk3.extraConfig = {gtk-application-prefer-dark-theme = 1;};
    gtk4.extraConfig = {gtk-application-prefer-dark-theme = 1;};
    gtk3 = {bookmarks = bookmarks;};
  };

  home.packages = with pkgs; [
    # GTK settings editor
    nwg-look
  ];

  # GTK applications: auto set cursor theme and size
  home.pointerCursor.gtk.enable = true;

  # Enable GNOME dconf, which is used by some GTK applications
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };
}
