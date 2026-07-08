{
  pkgs,
  lib,
  config,
  ...
}: {
  home.file.".config/tmux/themepack" = {
    source = ./themepack;
    recursive = true;
  };

  programs = {
    tmux = {
      enable = true;
      # Keep sesh on prefix+s with a custom fzf action set.
      extraConfig =
        builtins.readFile ./tmux.conf
        + ''
          bind-key "s" run-shell "sesh connect \"$(
            sesh list --icons | fzf --tmux 80%,70% \
              --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
              --header '  ^a all ^t tmux ^g configs ⌥c zoxide ^x tmux kill ^f find' \
              --bind 'tab:down,btab:up' \
              --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
              --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list --icons -t)' \
              --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list --icons -c)' \
              --bind 'alt-c:change-prompt(📁  )+reload(sesh list --icons -z)' \
              --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
              --bind 'ctrl-x:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
              --preview-window 'right:55%' \
              --preview 'sesh preview {}' \
              -- --ansi
          )\""
        '';
      plugins = with pkgs.tmuxPlugins; [
        # {
        #   plugin = dracula;
        #   extraConfig = ''
        #     set -g @dracula-show-battery false
        #     set -g @dracula-show-powerline false
        #     set -g @dracula-refresh-rate 100
        #   '';
        # }
        {
          plugin = resurrect;
          extraConfig = ''
            resurrect_dir="${config.xdg.stateHome}/tmux-ressurect"
            set -g @resurrect-dir $resurrect_dir
            set -g @resurrect-save 'S'
            set -g @resurrect-restore 'R'
            set -g @resurrect-capture-pane-contents 'on'
            # for vim
            set -g @resurrect-strategy-vim 'session'
            # for neovim
            set -g @resurrect-strategy-nvim 'session'
            # fix tmux-resurrect in neovim
            # https://discourse.nixos.org/t/how-to-get-tmux-resurrect-to-restore-neovim-sessions/30819
            set -g @resurrect-hook-post-save-all "sed -E -i 's| --cmd .*-vim-pack-dir||g; s|/nix/store[^ ]+bin/||g; s| --cmd lua||g; s|/etc/profiles/per-user/$USER/bin/||g; s|vim.g[^ ]+nvim-ruby[^ ]+||g' $(readlink -f $resurrect_dir/last)"
          '';
        }
        {
          plugin = tmux-floax;
          extraConfig = ''
            set -g @floax-border-color 'blue'
          '';
        }
      ];
    };

    # use sesh in tmux need fzf tmux enable
    fzf.tmux.enableShellIntegration = true;
    fzf.tmux.shellIntegrationOptions = ["-d 80%"];
    sesh = {
      # Whether to enable the sesh terminal session manager
      enable = true;
      enableAlias = false;
      # disable tmux integration, manually set the session in tmux.conf
      enableTmuxIntegration = false;
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
