```bash
git submodule init
git submodule update --remote
sudo nixos-rebuild switch --flake '.?submodules=1#deskmini'
```
