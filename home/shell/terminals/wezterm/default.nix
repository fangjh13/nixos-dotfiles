{ pkgs-unstable, ... }: {
  programs.wezterm = {
    enable = true;
    package = pkgs-unstable.wezterm;
    # FIXME: temporarily disable because of neovim in tmux open terminal print chao message
    # https://github.com/wez/wezterm/issues/5007
    enableZshIntegration = false;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
}
