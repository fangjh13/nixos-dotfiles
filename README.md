## NixOS

### Packages

| Component                 | Package                                                                                                                                         |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Compositor                | [hyprland](https://hyprland.org/)                                                                                                               |
| Login manager             | [greetd](https://git.sr.ht/~kennylevinsen/greetd)                                                                                               |
| Graphical console greeter | [tuigreet](https://github.com/apognu/tuigreet)                                                                                                  |
| Application launcher      | [rofi-wayland](https://github.com/lbonn/rofi)                                                                                                   |
| Theme                     | [catppuccin/nix](https://github.com/catppuccin/nix)                                                                                             |
| Status bar                | [waybar](https://github.com/Alexays/Waybar)                                                                                                     |
| Notifications daemons     | [swaynotificationcenter](https://github.com/ErikReider/SwayNotificationCenter)                                                                  |
| Screen lock               | [hyprlock](https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/)                                                                                  |
| File manager              | [thunar](https://gitlab.xfce.org/xfce/thunar)                                                                                                   |
| GUI PolicyKit agent       | [lxqt-policykit](https://github.com/lxqt/lxqt-policykit)                                                                                        |
| Clipboard manager         | [cliphist](https://github.com/sentriz/cliphist)                                                                                                 |
| Terminal                  | [kitty](https://github.com/kovidgoyal/kitty)                                                                                                    |
| Shell                     | [zsh](https://www.zsh.org/)                                                                                                                     |
| Editor                    | [neovim](https://neovim.io/)                                                                                                                    |
| Input method              | [fcitx5](https://github.com/fcitx/fcitx5) + [fcitx5-rime](https://github.com/fcitx/fcitx5-rime)                                                 |
| Screenshots Tools         | [slurp](https://github.com/emersion/slurp) + [grim](https://gitlab.freedesktop.org/emersion/grim) + [swappy](https://github.com/jtheoof/swappy) |
| Password manager          | [keepassxc](https://keepassxc.org/)                                                                                                             |

### Install

#### Requirements

- nixos system
- git command installed

---

#### Install NixOS

```shell
nix-shell -p git
git clone https://github.com/fangjh13/nixos-dotfiles.git
cd nixos-dotfiles

git submodule update --init --recursive --remote

export NIX_CONFIG="experimental-features = nix-command flakes"
nix run .#init
sudo nixos-rebuild switch --flake '.?submodules=1#<your hostname>'
```

`nix run .#init` performs Inventory onboarding for the current machine only. It
detects and confirms the local Nix system, then prompts for the Host name,
username, timezone, and Git identity. The candidate is generated and evaluated
in OS temporary storage before its directory is atomically registered in
`hosts/`. On success, only `hosts/<your hostname>` is staged with `git add`; no
commit is created. On failure, the Host inventory is unchanged and the command
prints the preserved staging path for inspection.

Each real Host directory is self-registering through `host.nix`:

```nix
{
  system = "x86_64-linux";
  username = "fython";
}
```

The directory name is the Host name. Reusable Host templates live separately
under `hosts/templates/` and never become inventory members. Host-specific
settings remain in `hosts/<your hostname>/variables.nix`.

| Variable | Description                                    |
| -------- | ---------------------------------------------- |
| useGUI   | Enable graphical user interface. i.e. hyprland |
| monitor  | Monitor config for hyprland                    |
| timezone | Timezone for the system                        |

> Some optional configurations (like graphic driver) can be enabled in `hosts/<your hostname>/default.nix`

#### Manual Install

Clone this repo and enter it. Copy the Linux Host template, then add a matching
`host.nix` declaration:

```shell
cp -r hosts/templates/linux hosts/<your hostname>
```

Generate system config from your system

```shell
# override the hardware config
sudo nixos-generate-config --show-hardware-config > hosts/<your hostname>/hardware-configuration.nix
```

Modify the configuration to belong to your computer `hosts/<your hostname>` files, build and switch with verbose output

```shell
sudo nixos-rebuild switch --flake '.?submodules=1#<your hostname>' --show-trace --print-build-logs --verbose
```

## nix-darwin

### Install

Install dependencies

```shell
xcode-select --install
```

Install [Nix](https://nixos.org/download/#nix-install-macos)

```shell
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

Now can clone this repo and build the system configuration with nix

```shell
git clone https://github.com/fangjh13/nixos-dotfiles.git
cd nixos-dotfiles

git submodule update --init --recursive --remote

export NIX_CONFIG="experimental-features = nix-command flakes"
nix run .#init
nix build '.?submodules=1#darwinConfigurations.<your hostname>.system'
sudo ./result/sw/bin/darwin-rebuild switch --flake '.?submodules=1#<your hostname>'
unlink ./result
```

After the first time build and switch, you installed the `darwin-rebuild` command, so you can directly use it to switch the system configuration without using nix

```shell
sudo darwin-rebuild switch --flake '.?submodules=1#<your hostname>'
```

Darwin uses the same Inventory onboarding transaction and prompts. It detects
the current Apple Silicon Mac as `aarch64-darwin` and does not run the
Linux-only hardware generator.

## Host inventory checks

All real Host declarations are discovered from their directories and exported
at the same time. Evaluate the complete
inventory contract on the current platform with:

```shell
nix flake check '.?submodules=1' --no-build
```

This standard check validates every inventory member's declaration, settings,
output membership, target platform, module state, and full top-level derivation
without requiring `--all-systems`. It evaluates other CPU/OS platforms but does
not build or activate their system closures; cross-platform builds still
require suitable remote builders or the native platform.

Build or temporarily activate one Host explicitly:

```shell
sudo nixos-rebuild test --flake '.?submodules=1#<linux-host>'
nix build '.?submodules=1#darwinConfigurations.<darwin-host>.system'
```

## Secrets

This repository manages encrypted files with SOPS and decrypts them during
NixOS or nix-darwin activation through sops-nix. Keep host-only files in
`hosts/<hostname>/secrets/`; keep shared, opt-in secret modules in
`modules/public/secrets/<scope>/`.

The shared creation rule accepts one file directly below each `<scope>` with a
`.yaml`, `.jsonc`, `.json`, `.ini`, or `.toml` extension. See
[`docs/secrets.md`](docs/secrets.md) for recipient setup, structured versus
whole-file binary formats, rotation, and activation guidance.
