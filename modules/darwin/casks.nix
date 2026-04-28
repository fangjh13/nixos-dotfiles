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

    # Cloud storage clients
    "synology-drive"

    # Screenshot tools
    "shottr"

    # QEMU Virtual Machines
    "utm"

    # Docker/k8s management
    "orbstack"

    # Markdown editor
    "markedit"
    "obsidian"

    # Note-taking tools
    "logseq"

    # Browsers
    "firefox"
    "google-chrome"

    # media player
    "iina"

    # file archiver
    "keka"
  ]
  # caks enabled from hosts/${host}/variables.nix variables.
  ++ casks
