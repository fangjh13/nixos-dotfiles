```bash
git submodule init
git submodule update --remote
sudo nixos-rebuild switch --flake '.?submodules=1#deskmini'
```

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
