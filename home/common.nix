{
  lib,
  pkgs,
  config,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    # archives
    zip
    unzip
    unrar
    xz
    p7zip

    # utils
    psmisc
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
    ncdu # disk usage analyzer
    duf # `df` alternative
    tlrc # Official `tldr` client written in Rust
    lshw
    dmidecode
    glow # markdown viewer on CLI
    chafa # image viewer on CLI

    # cloud native
    docker-compose
    kubectl
    devspace

    # db related
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

    # https://devenv.sh Developer Environments using Nix
    pkgs-unstable.devenv

    # man doc
    man-pages
    man-pages-posix

    # command line ai coding
    claude-code
  ];

  programs = {
    bat = {
      enable = true;
      config = {pager = "less -FR";};
    };

    btop = {
      enable = true; # replacement of htop/nmon
      settings = {vim_keys = true;};
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
      options = {selection-clipboard = "clipboard";};
    };

    # ssh client
    ssh = {
      enable = true;
      includes = ["config.d/*"];
      extraConfig = ''
        SendEnv LANG LC_*
      '';
      enableDefaultConfig = false;
      matchBlocks."*" = {
        forwardAgent = true;
        addKeysToAgent = "yes";
      };
    };
  };

  services = {
    # auto mount usb drives
    udiskie.enable = true;

    # enable OpenSSH private key agent
    ssh-agent.enable = true;
  };
}
