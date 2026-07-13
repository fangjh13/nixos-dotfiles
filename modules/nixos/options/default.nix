{
  imports = [
    ./intel-drivers.nix
    ./amdgpu-drivers.nix
    ./nvidia-drivers.nix
    ./pulseaudio.nix
    ./pipewire.nix
    ./zen-kernel.nix
    ./docker.nix
    ./podman.nix
    ./nfs.nix
    ./rclone.nix
    ./qemu.nix
  ];
}
