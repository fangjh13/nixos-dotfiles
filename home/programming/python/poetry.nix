{
  lib,
  pkgs,
  ...
}: let
  nixpkgs-pinned = import (pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "882842d2a908700540d206baa79efb922ac1c33d";
    sha256 = "sha256-+HBffoSXLhuNJtjxHOZYIyY+PQirlwHKMrir+xIUu4A=";
  }) {system = pkgs.stdenv.hostPlatform.system;};
  poetry_1_8_4 = nixpkgs-pinned.poetry;
in {
  programs.poetry = {
    enable = true;
    package = poetry_1_8_4;
    settings = {
      keyring.enabled = false;
      virtualenvs.create = true;
      virtualenvs.in-project = true;
    };
  };
}
