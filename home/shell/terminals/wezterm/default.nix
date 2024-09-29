{ pkgs, ... }: {
  programs.wezterm = {
    enable = true;
    # FIXME: temporarily disable because of neovim in tmux open terminal print chao message
    # https://github.com/wez/wezterm/issues/5007
    enableZshIntegration = false;
  };
}
