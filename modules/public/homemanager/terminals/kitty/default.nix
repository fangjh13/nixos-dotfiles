{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    extraConfig =
      if pkgs.stdenv.isLinux
      then (builtins.readFile ./kitty-linux.conf)
      else (builtins.readFile ./kitty-macos.conf);
  };
}
