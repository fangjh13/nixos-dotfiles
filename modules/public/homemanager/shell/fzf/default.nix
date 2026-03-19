# A command-line fuzzy finder
{pkgs, ...}: {
  programs = {
    fzf = let
      fdOptions = "--follow --hidden --exclude .git --color=always";
      copyCommand = ''
        ${
          if pkgs.stdenvNoCC.isLinux
          then
            # Wayland use wl-copy or X windows use xclip
            if pkgs.wlroots != null
            then "wl-copy"
            else "xclip -sel clip"
          else "pbcopy"
        }
      '';
      fzfPreviewScript = pkgs.writeTextFile {
        name = "fzf-preview.sh";
        text = builtins.readFile ./fzf-preview.sh;
        executable = true;
      };
      FullOpts = [
        "--style full"
        "--border --padding 1,2"
        "--border-label ' FZF ' --input-label ' Input ' --header-label ' File Type '"
        ''
          --bind 'result:transform-list-label:
            if [ -z \"\$FZF_QUERY\" ]; then
              echo \" \$FZF_MATCH_COUNT items \"
            else
              echo \" \$FZF_MATCH_COUNT matches for [\$FZF_QUERY] \"
            fi
          ' \
        ''
        ''--bind 'focus:transform-preview-label:[ -n \"{}\" ] && printf \" Previewing [%s] \" {}' ''
        ''--bind 'focus:+transform-header:file --brief {} || echo \"No file selected\"' ''
        "--bind 'ctrl-r:change-list-label( Reloading the list )+reload(sleep 2; git ls-files)'"
        "--color 'border:#aaaaaa,label:#cccccc'"
        "--color 'preview-border:#9999cc,preview-label:#ccccff'"
        "--color 'list-border:#669966,list-label:#99cc99'"
        "--color 'input-border:#996666,input-label:#ffcccc'"
        "--color 'header-border:#6699cc,header-label:#99ccff'"
        "--preview='${fzfPreviewScript} {}'"
      ];
    in {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      # FZF_DEFAULT_COMMAND
      defaultCommand = "git ls-tree -r --name-only HEAD --cached --others --exclude-standard || fd --type f --type l ${fdOptions}";
      # FZF_DEFAULT_OPTS
      defaultOptions = [
        "--no-mouse"
        "--select-1"
        "--multi"
        "--inline-info"
        "--ansi"
        "--layout=reverse"
        # <f3>: open file with bat or less
        # <ctrl-w>: toggle preview
        # <ctrl-d>: half page down
        # <ctrl-u>: half page up
        # <ctrl-a>: select all
        # <ctrl-o>: toggle all selections
        # <ctrl-y>: copy file name
        "--bind='f3:execute(bat --style=numbers {} || less -f {}),ctrl-w:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all,ctrl-o:toggle-all,ctrl-y:execute-silent(echo {+} | ${copyCommand})'"
        # <ctrl-g>: Re-filtering of filtered results can be repeated
        "--bind='ctrl-g:+clear-selection+select-all+clear-query+execute-silent:touch /tmp/wait-result'"
        "--bind='result:+transform:[ -f /tmp/wait-result ] && { rm /tmp/wait-result; echo +toggle-all+exclude-multi; }'"
      ];
      # FZF_CTRL_T_COMMAND
      fileWidgetCommand = "fd ${fdOptions}";
      # FZF_CTRL_T_OPTS
      fileWidgetOptions = ["--layout=default" "--height=80%"] ++ FullOpts;
      # FZF_CTRL_R_OPTS
      historyWidgetOptions = [
        "--layout=default"
        "--height=80%"
        "--style minimal"
        "--preview 'echo {}'"
        "--preview-window up:3:hidden:wrap"
        "--bind 'ctrl-y:execute-silent(echo -n {2..} | ${copyCommand})+abort'"
        "--color header:italic"
        "--header 'Press CTRL-Y to copy command into clipboard'"
      ];
      # FZF_ALT_C_COMMAND
      changeDirWidgetCommand = "fd --type d ${fdOptions}";
      changeDirWidgetOptions = ["--height=80%"] ++ FullOpts;
    };
  };
}
