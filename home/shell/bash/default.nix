{ config, ... }: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      stty werase undef
      bind '\C-w:unix-filename-rubout'
    '';
  };
}
