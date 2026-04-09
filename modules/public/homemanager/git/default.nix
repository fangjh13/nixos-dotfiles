{
  pkgs,
  lib,
  host,
  ...
}: let
  inherit (import ../../../../hosts/${host}/variables.nix) gitName gitEmail;
in {
  home.packages = [pkgs.gh];

  programs.git = {
    enable = true;

    settings = {
      user.name = "${gitName}";
      user.email = "${gitEmail}";

      alias = {
        cleanup = "!git branch --merged | grep  -v '\\*\\|main\\|master\\|develop\\|dev' | xargs -n 1 -r git branch -d";
        prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      };
      core = {
        editor = "nvim";
        ignorecase = false;
        quotepath = false;
      };
      merge = {
        conflictstyle = "diff3";
        tool = "nvimdiff";
      };
      mergetool.keepBackup = false;
      mergetool.nvimdiff.layout = "LOCAL,BASE,REMOTE / MERGED";
      rerere = {
        # remember how merges were resolved
        enable = true;
        autoupdate = true;
      };
      diff = {colorMoved = "default";};
      init = {defaultBranch = "main";};
      pull.rebase = true;
      push.autoSetupRemote = true;
      log.date = "local";
    };

    hooks = {
      prepare-commit-msg = ./hooks/prepare-commit-msg.sh;
    };
  };

  # git commit prompt
  xdg.configFile."prompt/git-commit-msg.md" = {
    # from https://github.com/theorib/git-commit-message-ai-prompt
    # https://github.com/Sitoi/ai-commit/tree/main/prompt
    source = ./hooks/git-commit-msg.md;
  };

  # syntax-highlighting pager for git
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      true-color = "always";
      navigate = true; # use n and N to move between diff sections
      light =
        false; # set to true if you're in a terminal w/ a light background color (e.g. the default macOS terminal)
      line-numbers = true;
      side-by-side = true;
      line-numbers-left-format = "";
      line-numbers-right-format = "│ ";
      interactive = {keep-plus-minus-markers = false;};
      features = "decorations";
      decorations = {
        commit-decoration-style = "blue ol";
        commit-style = "raw";
        file-style = "omit";
        hunk-header-decoration-style = "blue box";
        hunk-header-file-style = "red";
        hunk-header-line-number-style = "#067a00";
        hunk-header-style = "file line-number syntax";
        minus-style = ''normal "#361010"'';
      };
    };
  };
}
