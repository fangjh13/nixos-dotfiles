{ config, lib, ... }: {
  home.sessionVariables.STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";

  # starship prompt
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = false;
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.starship.settings
    settings = {
      add_newline = false;
      scan_timeout = 60;
      command_timeout = 1000;
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[✗](bold red)";
        vimcmd_symbol = "[V](bold green)";
      };
      shlvl.disabled = false;
      nix_shell.heuristic = true;
    };
  };
}
