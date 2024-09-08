{ lib, pkgs, catppuccin-bat, pkgs-unstable, ... }: {
  home.packages = with pkgs; [
    neofetch
    # disk usage analyzer 
    ncdu
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
    moreutils # sponge chronic errno ...

    htop
    tree
    android-tools
    dnsutils

    # misc
    libnotify
    wineWowPackages.wayland
    xdg-utils
    graphviz
    duf # `df` alternative
    tlrc # Official `tldr` client written in Rust
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

    # A command-line fuzzy finder
    fzf = let
      fdOptions = "--follow --hidden --exclude .git --color=always";
      copyCommand = ''
        ${if pkgs.stdenvNoCC.isLinux then
          "${pkgs.xclip}/bin/xclip -sel clip"
        else
          "pbcopy"}
      '';
    in {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      # FZF_DEFAULT_COMMAND
      defaultCommand =
        "git ls-tree -r --name-only HEAD --cached --others --exclude-standard || fd --type f --type l ${fdOptions}";
      # FZF_DEFAULT_OPTS
      defaultOptions = [
        "--no-mouse"
        "--height 50%"
        "--select-1"
        "--reverse"
        "--multi"
        "--inline-info"
        "--ansi"
        "--preview='[[ -d {} ]] && eza --tree --color=always {} || ([[ \\$(file --mime {}) =~ binary ]] && echo {} is a binary file) || (bat --style=numbers --color=always --line-range=:500 {} || highlight -O ansi -l {} || coderay {} || rougify {} || cat {}) 2> /dev/null | head -300'"
        "--preview-window='right:hidden:wrap'"
        "--bind='f3:execute(bat --style=numbers {} || less -f {}),ctrl-w:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept,ctrl-y:execute-silent(echo {+} | ${copyCommand})'"
      ];
      # FZF_CTRL_T_COMMAND
      fileWidgetCommand = "fd ${fdOptions}";
      # FZF_CTRL_R_OPTS
      historyWidgetOptions = [ "--layout=default" ];
      # FZF_ALT_C_COMMAND
      changeDirWidgetCommand = "fd --type d ${fdOptions}";
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
