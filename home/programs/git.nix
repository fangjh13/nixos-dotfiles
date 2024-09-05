{ pkgs, ... }: {
  home.packages = [ pkgs.gh ];

  programs.git = {
    enable = true;

    # FIXME: replace your git username and email
    userName = "Fython";
    userEmail = "fang.jia.hui123@gmail.com";

    extraConfig = {
      core = {
        editor = "nvim";
        ignorecase = false;
        quotepath = false;
      };
      init = { defaultBranch = "main"; };
    };
  };
}
