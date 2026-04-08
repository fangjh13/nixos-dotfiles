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

Clone this repo to local and enter it.

```shell
nix-shell -p git
git clone https://github.com/fangjh13/nixos-dotfiles.git
cd nixos-dotfiles
```

Create your host in `hosts` copy from `example` hosts

```shell
cp -r hosts/example hosts/<your hostname>
```

Modify the configuration to belong to your computer

```shell
# override the hardware config
sudo nixos-generate-config --show-hardware-config > hosts/<your hostname>/hardware-configuration.nix
```

📝 Change the hostname and username in `flake.nix` and some other configurations in `hosts/<your hostname>/variables.nix`

| Variable | Description                                    |
| -------- | ---------------------------------------------- |
| useGUI   | Enable graphical user interface. i.e. hyprland |
| monitor  | Monitor config for hyprland                    |
| timezone | Timezone for the system                        |

> Some optional configurations (like graphic driver) can be enabled in `hosts/<your hostname>/default.nix`

Rebuild NixOS

```shell
git submodule init
git submodule update --remote

export NIX_CONFIG="experimental-features = nix-command flakes"
nix run .#init
git add .
sudo nixos-rebuild switch --flake '.?submodules=1#<your hostname>'

# Debug Mode
# sudo nixos-rebuild switch --flake '.?submodules=1#<your hostname>' --show-trace --print-build-logs --verbose

# submodule update
# git submodule sync --recursive
# git submodule update --init --recursive
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

git submodule init
git submodule update --remote

export NIX_CONFIG="experimental-features = nix-command flakes"
nix run .#init
git add .
nix build '.?submodules=1#darwinConfigurations.<your hostname>.system'
sudo ./result/sw/bin/darwin-rebuild switch --flake '.?submodules=1#<your hostname>'
unlink ./result
```

After the first time build and switch, you installed the `darwin-rebuild` command, so you can directly use it to switch the system configuration without using nix
```shell
sudo darwin-rebuild switch --flake '.?submodules=1#<your hostname>'

```
