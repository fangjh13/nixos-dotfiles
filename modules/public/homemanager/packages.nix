{pkgs, ...}:
with pkgs; [
  # archives
  zip
  p7zip
  unrar
  xz

  # utils
  htop
  tree
  moreutils # sponge chronic errno ...
  ripgrep # recursively searches directories for a regex pattern
  yq-go # yaml processor https://github.com/mikefarah/yq
  tokei # count code, quickly
  android-tools
  fastfetch
  ncdu # disk usage analyzer
  tlrc # Official `tldr` client written in Rust
  duf # `df` alternative
  glow # markdown viewer on CLI
  ffmpeg

  # db related
  litecli # sqlite
  # mycli # mysql
  pgcli # postgresql
  iredis # redis
]
