{ pkgs, config, ... }: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export SHELL=bash

      stty werase undef
      bind '\C-w:unix-filename-rubout'

      # disable ctrl-s (freeze terminal)
      if [[ -t 0 && $- = *i* ]]
      then
        stty -ixon
        bind -r "\C-s"
      fi
    '';
  };
}
