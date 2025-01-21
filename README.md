### Packages

| Package                                                                                         | Description               |
| ----------------------------------------------------------------------------------------------- | ------------------------- |
| [hyprland](https://hyprland.org/)                                                               | Compositor                |
| [greetd](https://git.sr.ht/~kennylevinsen/greetd)                                               | Login manager             |
| [tuigreet](https://github.com/apognu/tuigreet)                                                  | Graphical console greeter |
| [rofi-wayland](https://github.com/lbonn/rofi)                                                   | Application launcher      |
| [waybar](https://github.com/Alexays/Waybar)                                                     | Status bar                |
| [swaynotificationcenter](https://github.com/ErikReider/SwayNotificationCenter)                  | Notifications daemons     |
| [thunar](https://gitlab.xfce.org/xfce/thunar)                                                   | File manager              |
| [lxqt-policykit](https://github.com/lxqt/lxqt-policykit)                                        | GUI PolicyKit agent       |
| [cliphist](https://github.com/sentriz/cliphist)                                                 | Clipboard manager         |
| [kitty](https://github.com/kovidgoyal/kitty)                                                    | Terminal                  |
| [zsh](https://www.zsh.org/)                                                                     | Shell                     |
| [neovim](https://neovim.io/)                                                                    | Editor                    |
| [fcitx5](https://github.com/fcitx/fcitx5) + [fcitx5-rime](https://github.com/fcitx/fcitx5-rime) | Input method              |

### Install

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

> Some optional configurations (like graphic driver) can be enabled in `hosts/<your hostname>/default.nix`

Rebuild NixOS

```shell
git add .
git submodule init
git submodule update --remote
NIX_CONFIG="experimental-features = nix-command flakes"
sudo nixos-rebuild switch --flake '.?submodules=1#<your hostname>'
```
