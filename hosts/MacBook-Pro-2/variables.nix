{
  userName = "fython";
  hostName = "MacBook-Pro-2";
  gitName = "fangjh";
  gitEmail = "fangjh@pmind-tech.com";

  timezone = "Asia/Shanghai";

  # Extra Homebrew formula packages to be installed
  brews = [
    {
      name = "frpc";
      restart_service = "changed";
    }
  ];

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

    "wechat"
    "telegram"
    "feishu"
    "apifox"
    "codex-app"
    "iina"
  ];
}
