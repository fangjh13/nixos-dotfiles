{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    extraConfig =
      if pkgs.stdenv.hostPlatform.isLinux
      then (builtins.readFile ./kitty-linux.conf)
      else (builtins.readFile ./kitty-macos.conf);
  };
}
