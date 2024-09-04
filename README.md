```bash
git submodule init
git submodule sync
sudo nixos-rebuild switch --flake '.?submodules=1#deskmini'
```
