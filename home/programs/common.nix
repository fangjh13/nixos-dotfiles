{ lib, pkgs, catppuccin-bat, pkgs-unstable, ... }: {
  home.packages = with pkgs; [
    neofetch
    # archives
    zip
    unzip
    unrar
    xz
    p7zip

    # utils
    file
    ripgrep # recursively searches directories for a regex pattern
    yq-go # yaml processor https://github.com/mikefarah/yq
    fzf # A command-line fuzzy finder

    htop
    tree
    android-tools

    # misc
    libnotify
    wineWowPackages.wayland
    xdg-utils
    graphviz
    duf # 'df' alternative
    tlrc # Official tldr client written in Rust
    evince # pdf viewer

    # productivity
    obsidian

    # IDE
    insomnia # API debug

    # cloud native
    docker-compose
    kubectl

    nodejs
    nodePackages.npm
    nodePackages.pnpm
    yarn

    # db related
    dbeaver-bin
    mycli
    pgcli

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    # A (h)top like task monitor for AMD, Adreno, Intel and NVIDIA GPUs
    nvtopPackages.full

    # Synology Drive Client
    pkgs.synology-drive-client
    # password manager           
    keepassxc
    # notebook
    pkgs.logseq

    # Programming Languages
    gcc
    gnumake
    cmake
  ];

  programs = {
    neovim = {
      package = pkgs-unstable.neovim-unwrapped;
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
    fd.enable = true; # replacement of find
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
    # auto mount usb drives
    udiskie.enable = true;

    # clipboard manager
    copyq.enable = true;

    # enable OpenSSH private key agent
    ssh-agent.enable = true;
  };
}
