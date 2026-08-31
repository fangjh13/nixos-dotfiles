{
  pkgs,
  hostContext,
  ...
}: let
  inherit (hostContext) username;
in {
  users.users.${username} = {
    name = "${username}";
    home = "/Users/${username}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };

}
