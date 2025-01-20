{ lib, pkgs, config, ... }:
with lib;
let cfg = config.kernel.zen;
in {
  options.kernel.zen = { enable = mkEnableOption "Use Zen Kernel"; };

  config = mkIf cfg.enable { boot.kernelPackages = pkgs.linuxPackages_zen; };
}

