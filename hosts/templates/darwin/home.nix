{
  imports = [../../modules/public/homemanager/terminals/ghostty];

  programs = {
    git.settings.user = {
      name = "%%GITNAME%%";
      email = "%%GITEMAIL%%";
    };
    ghostty.enable = true;
  };
}
