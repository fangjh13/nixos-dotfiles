### Packages

| Package                                                                                                                                         | Description               |
| ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| [hyprland](https://hyprland.org/)                                                                                                               | Compositor                |
| [greetd](https://git.sr.ht/~kennylevinsen/greetd)                                                                                               | Login manager             |
| [tuigreet](https://github.com/apognu/tuigreet)                                                                                                  | Graphical console greeter |
| [rofi-wayland](https://github.com/lbonn/rofi)                                                                                                   | Application launcher      |
| [waybar](https://github.com/Alexays/Waybar)                                                                                                     | Status bar                |
| [swaynotificationcenter](https://github.com/ErikReider/SwayNotificationCenter)                                                                  | Notifications daemons     |
| [hyprlock](https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/)                                                                                  | Screen lock               |
| [thunar](https://gitlab.xfce.org/xfce/thunar)                                                                                                   | File manager              |
| [lxqt-policykit](https://github.com/lxqt/lxqt-policykit)                                                                                        | GUI PolicyKit agent       |
| [cliphist](https://github.com/sentriz/cliphist)                                                                                                 | Clipboard manager         |
| [kitty](https://github.com/kovidgoyal/kitty)                                                                                                    | Terminal                  |
| [zsh](https://www.zsh.org/)                                                                                                                     | Shell                     |
| [neovim](https://neovim.io/)                                                                                                                    | Editor                    |
| [fcitx5](https://github.com/fcitx/fcitx5) + [fcitx5-rime](https://github.com/fcitx/fcitx5-rime)                                                 | Input method              |
| [slurp](https://github.com/emersion/slurp) + [grim](https://gitlab.freedesktop.org/emersion/grim) + [swappy](https://github.com/jtheoof/swappy) | Screenshots Tools         |

### Install

#### Requirements

- nixos system
- git command installed

---

Clone this repo to local and enter it.

```shell
git clone ...
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

Change the hostname and username in `flake.nix` and some other configurations in `hosts/<your hostname>/variables.nix`

| Variable | Description                                    |
| -------- | ---------------------------------------------- |
| useGUI   | Enable graphical user interface. i.e. hyprland |
| monitor  | Monitor config for hyprland                    |
| timezone | Timezone for the system                        |

> Some optional configurations (like graphic driver) can be enabled in `hosts/<your hostname>/default.nix`

Rebuild NixOS

```shell
git add .
git submodule init
git submodule update --remote
export NIX_CONFIG="experimental-features = nix-command flakes"
sudo nixos-rebuild switch --flake '.?submodules=1#<your hostname>'
```
