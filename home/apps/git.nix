{ pkgs, ... }: {
  home.packages = [ pkgs.gh ];

  programs.git = {
    enable = true;

    # FIXME: replace your git username and email
    userName = "Fython";
    userEmail = "fang.jia.hui123@gmail.com";

    extraConfig = {
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
      diff = { colorMoved = "default"; };
      init = { defaultBranch = "main"; };
      pull.rebase = true;
    };

    # syntax-highlighting pager for git
    delta = {
      enable = true;
      options = {
        true-color = "always";
        features = "decorations";
        navigate = true; # use n and N to move between diff sections
        light =
          false; # set to true if you're in a terminal w/ a light background color (e.g. the default macOS terminal)
        line-numbers = true;
        side-by-side = true;
        line-numbers-left-format = "";
        line-numbers-right-format = "│ ";
        interactive = { keep-plus-minus-markers = false; };
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
  };
}
