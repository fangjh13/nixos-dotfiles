{
  pkgs,
  ...
}: {
  home.packages = [pkgs.gh];

  programs.git = {
    enable = true;

    userName = "Fython";
    userEmail = "fang.jia.hui123@gmail.com";

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };
}
