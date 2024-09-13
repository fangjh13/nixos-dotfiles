```bash
git submodule init
git submodule update
sudo nixos-rebuild switch --flake '.?submodules=1#deskmini'
```
