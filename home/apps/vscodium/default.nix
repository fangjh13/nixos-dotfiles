{ config, lib, pkgs, pkgs-unstable, ... }:

{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    # community-driven vscode, Telemetry is disabled.
    package = pkgs-unstable.vscodium;
    extensions = with pkgs-unstable.vscode-extensions; [
      vscodevim.vim # vim keybinding
      mkhl.direnv # direnv support
      jnoortheen.nix-ide # Nix language support
      golang.go # Go language
    ];
    userSettings = {
      "terminal.integrated.copyOnSelection" = true;
      # "terminal.integrated.fontFamily" = "'Hack Nerd Font Mono', 'JetbrainsMono Nerd Font', Monaco";
      workbench = { startupEditor = "none"; };

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
      "vim.normalModeKeyBindings" = [{
        before = [ "<leader>" "f" "s" ];
        commands = [ "workbench.action.files.save" ];
      }];

      # nix
      nix = {
        enableLanguageServer = true;
        # https://github.com/oxalica/nil
        serverPath = "${pkgs.nil}/bin/nil";
        serverSettings = {
          nil = { formatting = { command = [ "nixfmt" ]; }; };
        };
        formatterPath = "${pkgs.nixfmt-classic}/bin/nixfmt";
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
  # dependencies
  home.packages = with pkgs; [ nixfmt-classic nil ];
}

