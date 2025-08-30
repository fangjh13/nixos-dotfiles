{
  pkgs,
  pkgs-stable,
  config,
  ...
}: {
  programs = {
    firefox = {
      enable = true;
      # TODO: the latest unstable version 142.0 crashes use stable channel version 142
      package = pkgs-stable.firefox;
      policies = {
        DisablePocket = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        PasswordManagerEnable = false;
      };
      profiles = {
        default = {
          isDefault = true;
          settings = {
            "browser.cache.disk.enable" = false;
            "browser.cache.memory.enable" = true;
            "browser.cache.memory.capacity" = -1;
            "browser.sessionstore.resume_from_crash" = false;
            "browser.display.background_color" = "#FFFFFF";
            "browser.display.background_color.dark" = "#1C1B22";
            "browser.display.foreground_color" = "#000000";
            "browser.display.foreground_color.dark" = "#FBFBFE";
            "browser.search.hiddenOneOffs" = "Google,Amazon.com,Bing,DuckDuckGo,Wikipedia (en)";
            "browser.search.suggest.enabled" = true;
            "browser.urlbar.placeholderName" = "Google";
            "browser.urlbar.speculativeConnect.enabled" = true;
            "general.smoothScroll" = true;
            "security.insecure_connection_text.enabled" = true;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };
        };
      };
    };
  };
}
