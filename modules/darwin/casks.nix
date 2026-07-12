{
  lib,
  pkgs,
  host,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) casks;
in
  [
    # Spotlight alternatives
    "raycast"

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

    # file archiver
    "keka"
  ]
  # caks enabled from hosts/${host}/variables.nix variables.
  ++ casks
