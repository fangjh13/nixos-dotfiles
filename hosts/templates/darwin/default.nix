{hostContext, ...}: {
  imports = [./secrets];

  home-manager.users.${hostContext.username}.imports = [./home.nix];

  time.timeZone = "%%TIMEZONE%%";

  homebrew.casks = [
    "utm"
    "pixpin"
    "orbstack"
    "synology-drive"
    "markedit"
    "obsidian"
    "logseq"
  ];

  # Keep the installation compatibility version explicit and stable.
  system.stateVersion = 6;
}
