{pkgs, ...}: {
  # Enables GnuPG agent with socket-activation for every user session.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
