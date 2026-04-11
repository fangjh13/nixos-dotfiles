{
  lib,
  pkgs,
  host,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) casks;
in
  [
    # Automation tools
    "hammerspoon"
    "raycast"
    "squirrel-app"
    "keepassxc"
    "synology-drive"
    "logseq"
    # QEMU Virtual Machines
    "utm"
    "markedit"
    "obsidian"
    "firefox"
    "orbstack"
    "google-chrome"
    # media player
    "iina"
    # file archiver
    "keka"

    "antigravity"
  ]
  # caks enabled from hosts/${host}/variables.nix variables.
  ++ casks
