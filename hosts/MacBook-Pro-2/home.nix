{
  imports = [../../modules/public/homemanager/terminals/ghostty];

  programs = {
    git.settings.user = {
      name = "fangjh";
      email = "fangjh@pmind-tech.com";
    };
    ghostty.enable = true;
  };
}
