{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    package = pkgs.yazi.override {
      _7zz = pkgs._7zz-rar; # Support for RAR extraction
    };
    enableZshIntegration = true;
    # press q to quit, CWD changed to the current directory
    # press Q to quit, CWD is not changed
    shellWrapperName = "y";
  };
}
