{ lib, pkgs, config, pkgs-unstable, ... }: {
  home.packages = let
    scale-wechat-bwrap =
      pkgs.nur.repos.novel2430.wechat-universal-bwrap.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          wrapProgram $out/bin/wechat-universal-bwrap \
            --set QT_SCALE_FACTOR 1.5
        '';
      });
  in with pkgs;
  ([
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
    killall
    tree
    android-tools
    dnsutils
    tokei # count code, quickly
    fastfetch

    # misc
    openssl
    ffmpeg
    libnotify
    wineWowPackages.wayland
    xdg-utils
    graphviz
    ncdu # disk usage analyzer
    duf # `df` alternative
    tlrc # Official `tldr` client written in Rust
    lshw
    dmidecode

    # productivity
    obsidian

    # IDE
    insomnia # API debug

    # cloud native
    docker-compose
    kubectl

    # db related
    dbeaver-bin
    jetbrains.datagrip
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
    gpu-viewer

    # office
    libreoffice
    # https://devenv.sh Developer Environments using Nix
    pkgs-unstable.devenv
    # Synology Drive Client
    synology-drive-client
    # Password manager
    keepassxc
    # notebook
    logseq
    # IM
    scale-wechat-bwrap
    # wechat-uos
    telegram-desktop
    # man doc
    man-pages
    man-pages-posix
  ]
  # C/C++ Languages
    ++ [
      gcc
      gdb
      cmake
      gnumake
      checkmake
      pkg-config
    ]
    # Rust
    ++ [
      rustc
      pkgs-unstable.cargo # rust package manager
    ]
    # Web Development
    ++ [ nodePackages.nodejs nodePackages.yarn nodePackages.typescript ]);

  programs = {

    # A command-line fuzzy finder
    fzf = let
      fdOptions = "--follow --hidden --exclude .git --color=always";
      copyCommand = ''
        ${if pkgs.stdenvNoCC.isLinux then
        # Wayland use wl-copy or X windows use xclip
          if pkgs.wlroots != null then "wl-copy" else "xclip -sel clip"
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
        # <ctrl-w>: text preview
        # <ctrl-y>: copy file name
        "--bind='f3:execute(bat --style=numbers {} || less -f {}),ctrl-w:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept,ctrl-y:execute-silent(echo {+} | ${copyCommand})'"
        # <ctrl-g>: Re-filtering of filtered results can be repeated
        "--bind='ctrl-g:+clear-selection+select-all+clear-query+execute-silent:touch /tmp/wait-result'"
        "--bind='result:+transform:[ -f /tmp/wait-result ] && { rm /tmp/wait-result; echo +toggle-all+exclude-multi; }'"
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
      config = { pager = "less -FR"; };
    };

    btop = {
      enable = true; # replacement of htop/nmon
      settings = { vim_keys = true; };
    };
    fd.enable = true; # replacement of find
    eza.enable = true; # A modern replacement for ‘ls’
    jq.enable = true; # A lightweight and flexible command-line JSON processor

    # pdf viewer
    zathura = {
      enable = true;
      package = pkgs.zathura.override {
        # https://wiki.archlinux.org/title/Zathura
        useMupdf = true;
      };
      options = { selection-clipboard = "clipboard"; };
    };

    # ssh client
    ssh = {
      enable = true;
      forwardAgent = true;
      addKeysToAgent = "yes";
      includes = [ "config.d/*" ];
      extraConfig = ''
        SendEnv LANG LC_*
      '';
    };

  };

  services = {
    # auto mount usb drives
    udiskie.enable = true;

    # enable OpenSSH private key agent
    ssh-agent.enable = true;
  };
}
