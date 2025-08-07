{
  config,
  lib,
  ...
}: {
  home.sessionVariables.STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";

  # starship prompt
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    # https://starship.rs/config/
    settings = {
      add_newline = false;
      scan_timeout = 60;
      command_timeout = 1000;
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[✗](bold red)";
        vimcmd_symbol = "[V](bold green)";
      };
      shlvl = {
        disabled = false;
        threshold = 3;
      };
      nix_shell = {
        impure_msg = "[impure shell](bold red)";
        pure_msg = "[pure shell](bold green)";
        unknown_msg = "";
        heuristic = true;
      };
    };
  };
}
