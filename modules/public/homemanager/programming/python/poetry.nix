{
  lib,
  pkgs,
  ...
}: let
  # nixpkgs-pinned = import (pkgs.fetchFromGitHub {
  #   owner = "NixOS";
  #   repo = "nixpkgs";
  #   rev = "882842d2a908700540d206baa79efb922ac1c33d";
  #   sha256 = "sha256-+HBffoSXLhuNJtjxHOZYIyY+PQirlwHKMrir+xIUu4A=";
  # }) {system = pkgs.stdenv.hostPlatform.system;};
  # poetry_1_8_4 = nixpkgs-pinned.poetry;

  # poetry 2.0.0
  nixpkgs-pinned = import (builtins.fetchGit {
         # Descriptive name to make the store path easier to identify
         name = "my-old-revision";
         url = "https://github.com/NixOS/nixpkgs/";
         ref = "refs/heads/nixpkgs-unstable";
         rev = "21808d22b1cda1898b71cf1a1beb524a97add2c4";
     }) {system = pkgs.stdenv.hostPlatform.system;};
  poetry = nixpkgs-pinned.poetry;
in {
  programs.poetry = {
    enable = true;
    package = poetry;
    settings = {
      keyring.enabled = false;
      virtualenvs.create = true;
      virtualenvs.in-project = true;
    };
  };
}
