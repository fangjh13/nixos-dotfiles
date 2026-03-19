{
  lib,
  pkgs,
  config,
  username,
  ...
}:
with lib; let
  cfg = config.addon.qemu;
in {
  options.addon.qemu = {enable = mkEnableOption "Enable QEMU Virtualisation";};

  # https://wiki.nixos.org/wiki/Libvirt
  config = mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        # Enable TPM emulation
        # install pkgs.swtpm system-wide for use in virt-manager
        swtpm.enable = true;
      };
    };
    users.users."${username}".extraGroups = ["libvirtd"];

    environment.systemPackages = with pkgs; [
      # Quickly create and run optimised Windows, macOS and Linux virtual machines
      quickemu
    ];
  };
}
