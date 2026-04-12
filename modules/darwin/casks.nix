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

    # Spotlight alternatives
    "raycast"

    # Input method
    "squirrel-app"

    "synology-drive"
    "logseq"

    # Screenshot tools
    "shottr"

    # QEMU Virtual Machines
    "utm"

    # Docker/k8s management
    "orbstack"

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
