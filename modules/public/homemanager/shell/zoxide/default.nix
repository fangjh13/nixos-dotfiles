{pkgs, ...}: {
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    # Replace the cd command
    options = ["--cmd cd"];
  };
}
