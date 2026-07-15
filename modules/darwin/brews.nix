{host, ...}: let
  inherit (import ../../hosts/${host}/variables.nix) brews;
in
  [
    "mas"
  ]
  # brews enabled from hosts/${host}/variables.nix variables.
  ++ brews
