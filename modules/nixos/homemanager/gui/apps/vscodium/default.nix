{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  programs.vscode = {
    enable = true;
    # community-driven vscode, Telemetry is disabled.
    package = pkgs-unstable.vscodium;
    # if you need Remote SSH extension use official vscode
    # package = pkgs-unstable.vscode;
    profiles.default = {
      enableUpdateCheck = false;
      extensions = with pkgs-unstable.vscode-extensions; [
        # vim keybinding
        vscodevim.vim
        # direnv support
        mkhl.direnv
        # Nix language support
        jnoortheen.nix-ide
        # Go language
        golang.go
        # Toml
        tamasfe.even-better-toml
        # Remote SSH
        # ms-vscode-remote.remote-ssh # can not use vscodium package
      ];
      userSettings = {
        "terminal.integrated.copyOnSelection" = true;
        # "terminal.integrated.fontFamily" = "'Hack Nerd Font Mono', 'JetbrainsMono Nerd Font', Monaco";
        workbench = {startupEditor = "none";};

        editor = {
          fontFamily = "'Hack Nerd Font Mono', 'JetbrainsMono Nerd Font', Monaco";
          fontLigatures = true;
          fontSize = 14;
          formatOnSave = true;
          inlineSuggest.enabled = true;
          bracketPairColorization.enabled = true;
        };

        "update.showReleaseNotes" = false;

        # Vim settings
        "vim.leader" = ",";
        "vim.useSystemClipboard" = true;
        "vim.normalModeKeyBindings" = [
          {
            before = ["<leader>" "f" "s"];
            commands = ["workbench.action.files.save"];
          }
        ];

        # nix
        nix = {
          enableLanguageServer = true;
          # https://github.com/oxalica/nil
          serverPath = "${pkgs.nil}/bin/nil";
          serverSettings = {
            nil = {formatting = {command = ["nixfmt"];};};
          };
          formatterPath = "${pkgs.nixfmt}/bin/nixfmt";
        };

        # go
        go = {
          inlayHints = {
            assignVariableTypes = true;
            compositeLiteralTypes = true;
            constantValues = true;
            functionTypeParameters = true;
            parameterNames = true;
            rangeVariableTypes = true;
          };
        };
        # gopls config: https://github.com/golang/tools/blob/master/gopls/doc/settings.md
        gopls = {
          semanticTokens = true;
          usePlaceholders = true;
        };
      };
    };
  };
  # dependencies
  home.packages = with pkgs; [nixfmt nil];
}
