{
  pkgs,
  pkgs-unstable,
  ...
}:
with pkgs; let
  publicPkgs = import ../../public/homemanager/packages.nix {inherit pkgs;};
in {
  home.packages =
    publicPkgs
    ++ [
      # utils
      file
      dnsutils
      openssl
      lshw
      dmidecode
      chafa # image viewer on CLI
      psmisc # killall, fuser, pstree, prtstat ...

      # cloud native
      docker-compose
      kubectl
      kubeconform # Kubernetes manifests validator
      devspace

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
    ];
}
