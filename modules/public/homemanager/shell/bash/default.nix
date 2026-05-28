{
  pkgs,
  config,
  ...
}: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export SHELL=bash

      if [[ -t 0 && $- == *i* ]]; then
        # Disable default TTY word erase and rebind it to path-aware deletion.
        # This makes Ctrl-W delete backwards up to a slash (/) instead of a space,
        # which is extremely useful when typing and correcting file paths.
        stty werase undef
        bind '\C-w:unix-filename-rubout'

        # Disable XON/XOFF software flow control.
        # This prevents the terminal from freezing (pausing output) when Ctrl-S is
        # pressed accidentally, and frees up Ctrl-S for other readline keybindings.
        stty -ixon
        bind -r "\C-s"
      fi
    '';
  };
}
