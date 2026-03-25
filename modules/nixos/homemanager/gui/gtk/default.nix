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

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        gtk-scheme = "WhiteSur-Dark-solid";
        color-scheme = "prefer-dark";
      };
    };
  };
}
