# Define a main user account for NixOS
{
  lib,
  pkgs,
  inputs,
  host,
  username,
  ...
}: let
  capitalize = str: let
    first = builtins.substring 0 1 str;
    rest = builtins.substring 1 (builtins.stringLength str - 1) str;
  in
    lib.toUpper first + rest;
in {
  # enable zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };
  environment.shells = [pkgs.bashInteractive pkgs.zsh];

  environment.pathsToLink = [
    # symlinked in `/run/current-system/sw` to get completion for system packages
    "/share/zsh"
    "/share/bash-completion"
  ];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # NOTE: Define a main user account
  users.users."${username}" = {
    isNormalUser = true;
    description = capitalize "${username}";
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [];
    shell = pkgs.zsh;
  };
}
