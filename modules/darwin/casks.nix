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

    # Browsers
    "firefox"
    "google-chrome"

    # file archiver
    "keka"
  ]
  # caks enabled from hosts/${host}/variables.nix variables.
  ++ casks
