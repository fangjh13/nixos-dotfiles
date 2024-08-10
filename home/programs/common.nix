{
  lib,
  pkgs,
  catppuccin-bat,
  ...
}: {
  home.packages = with pkgs; [
    # archives
    zip
    unzip
    p7zip

    # utils
    ripgrep
    yq-go # https://github.com/mikefarah/yq
    htop
    tree

    # misc
    libnotify
    wineWowPackages.wayland
    xdg-utils
    graphviz
    tlrc  # Official tldr client written in Rust

    # productivity
    obsidian

    # IDE
    insomnia

    # cloud native
    docker-compose
    kubectl

    nodejs
    nodePackages.npm
    nodePackages.pnpm
    yarn
    python3

    # db related
    dbeaver-bin
    mycli
    pgcli

    # Synology Drive Client
    pkgs.synology-drive-client
    # password manager           
    keepassxc
    # notebook
    pkgs.logseq
  ];

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
    };

    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "catppuccin-macchiato";
      };
      themes = {
        catppuccin-macchiato = {
          src = catppuccin-bat;
          file = "themes/Catppuccin Macchiato.tmTheme";
        };
	dracula = {
          src = pkgs.fetchFromGitHub {
            owner = "dracula";
            repo = "sublime"; # Bat uses sublime syntax for its themes
            rev = "456d3289827964a6cb503a3b0a6448f4326f291b";
            sha256 = "sha256-8mCovVSrBjtFi5q+XQdqAaqOt3Q+Fo29eIDwECOViro=";
          };
          file = "Dracula.tmTheme";
        };
      };
    
    };

    rofi = {
      enable = true;
      plugins = [ pkgs.rofi-calc ];
    };

    wezterm.enable = true;

    btop.enable = true; # replacement of htop/nmon
    fd.enable = true;  #  replacement of find
    eza.enable = true; # A modern replacement for ‘ls’
    jq.enable = true; # A lightweight and flexible command-line JSON processor

    # ssh client
    ssh = {
      enable = true;
      forwardAgent = true;
      addKeysToAgent = "yes";
    };

    skim = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "rg --files --hidden";
      changeDirWidgetOptions = [
        "--preview 'exa --icons --git --color always -T -L 3 {} | head -200'"
        "--exact"
      ];
    };
  };

  services = {
    syncthing.enable = true;

    # auto mount usb drives
    udiskie.enable = true;

    # clipboard manager
    copyq.enable = true;

    # enable OpenSSH private key agent
    ssh-agent.enable = true;
  };
}
