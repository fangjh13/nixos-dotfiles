{
  pkgs,
  lib,
  ...
}: {
  programs = {
    zsh = let
      mkZshPlugin = {
        pkg,
        file ? "${pkg.pname}.plugin.zsh",
      }: {
        name = pkg.pname;
        src = pkg.src;
        inherit file;
      };
    in {
      enable = true;
      autocd = true;
      enableCompletion = true;

      plugins = [
        (mkZshPlugin {pkg = pkgs.zsh-completions;}) # extra zsh-completions
        (mkZshPlugin {pkg = pkgs.zsh-autosuggestions;})
        (mkZshPlugin {
          pkg = pkgs.zsh-fast-syntax-highlighting;
          file = "fast-syntax-highlighting.plugin.zsh";
        })
        (mkZshPlugin {pkg = pkgs.zsh-history-substring-search;})
        # fzf-git.sh
        (mkZshPlugin {
          pkg = pkgs.fzf-git-sh;
          file = "fzf-git.sh";
        })
      ];

      oh-my-zsh = {
        enable = true;
        theme = ""; # disable theme use pure prompt
        plugins = ["git" "copypath" "copybuffer"];
      };

      dirHashes = {
        docs = "$HOME/Documents";
        dl = "$HOME/Downloads";
      };

      # manual add fpath for zsh-completions
      initContent = ''
        fpath+=$HOME/.zsh/plugins/zsh-completions/src
         ${lib.readFile ./extra.zshrc}'';

      sessionVariables = {
        LC_ALL = "en_US.UTF-8";
        LANG = "en_US.UTF-8";
      };

      shellAliases = {
        ll = "eza -alF --sort=modified --colour always";
        ls = "eza --color=always --git --no-filesize --icons=always --no-time --no-user --no-permissions --group-directories-first";
        # vim show special characters
        vidos = ''vim  -c ":e ++ff=unix" -c "set list"'';
        gbr = "git branch -r --sort=-committerdate --format='%(HEAD)%(color:yellow)%(refname:short)|%(color:bold green)%(committerdate:relative)|%(color:blue)%(subject)|%(color:magenta)%(authorname)%(color:reset)' --color=always | column -ts'|'";
        memTop = ''
          ps -e -o rss,args | awk '{print $1 " " $2 }' | awk '{tot[$2]+=$1;count[$2]++} END {for (i in tot) {print tot[i],i,count[i]}}' | sort -n'';
        # nix-history =
        #   "nix profile history --profile /nix/var/nix/profiles/system";
        # nix-clean-xdays =
        #   "sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than ";
        # nix-gc = "sudo nix store gc --debug";
      };
    };
  };
  home.packages = with pkgs; [
    any-nix-shell # zsh support for nix-shell
  ];
}
