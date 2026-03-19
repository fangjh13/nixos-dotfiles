{pkgs, ...}: {
  programs = {
    less = {
      enable = true;
    };

    bat = {
      enable = true;
      config = {pager = "less -FRX -i";};
    };

    btop = {
      enable = true; # replacement of htop/nmon
      settings = {vim_keys = true;};
    };
    fd.enable = true; # replacement of find
    eza.enable = true; # A modern replacement for ‘ls’
    jq.enable = true; # A lightweight and flexible command-line JSON processor

    # ssh client
    ssh = {
      enable = true;
      includes = ["config.d/*"];
      extraConfig = ''
        SendEnv LANG LC_*
      '';
      enableDefaultConfig = false;
      matchBlocks."*" = {
        forwardAgent = true;
        addKeysToAgent = "yes";
      };
    };
  };
}
