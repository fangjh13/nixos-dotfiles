{
  imports = [../../modules/public/homemanager/terminals/ghostty];

  programs = {
    git.settings.user = {
      name = "Fython";
      email = "fython.me@gmail.com";
    };
    ghostty.enable = true;
  };
}
