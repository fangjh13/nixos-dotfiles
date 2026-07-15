{
  userName = "%%USERNAME%%";
  hostName = "%%HOSTNAME%%";
  gitName = "%%GITNAME%%";
  gitEmail = "%%GITEMAIL%%";

  timezone = "%%TIMEZONE%%";

  # Extra Homebrew formula packages to be installed
  brews = [];

  # Extra Homebrew cask packages to be installed
  casks = [
    # QEMU Virtual Machines
    "utm"
    # Screenshot tools
    "pixpin"
    # Docker/k8s management
    "orbstack"
    # Cloud storage clients
    "synology-drive"
    # Markdown editor
    "markedit"
    "obsidian"
    # Note-taking tools
    "logseq"
  ];
}
