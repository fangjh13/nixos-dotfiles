{
  pkgs,
  lib,
  ...
}: {
  home.file.".config/tmux/themepack" = {
    source = ./themepack;
    recursive = true;
  };

  programs = {
    tmux = {
      enable = true;
      extraConfig = builtins.readFile ./tmux.conf;
    };

    # use sesh in tmux need fzf tmux enable
    fzf.tmux.enableShellIntegration = true;
    fzf.tmux.shellIntegrationOptions = ["-d 80%"];
    sesh = {
      # Whether to enable the sesh terminal session manager
      enable = true;
      enableTmuxIntegration = true;
      tmuxKey = "s";
      settings = {
        blacklist = ["scratch"];
        default_session = {
          # startup_command = "nvim -c ':Telescope find_files'";
          preview_command = "eza --all --git --icons --color=always {}";
        };
        session = [
          rec {
            name = "📌 todo";
            path = "~/.todo/todo.md";
            startup_command = "nvim ${path}";
            preview_command = "${lib.getExe pkgs.glow} ${path}";
          }
          {
            name = "🏠 config";
            path = "~/.config";
          }
        ];
      };
    };
  };
}
