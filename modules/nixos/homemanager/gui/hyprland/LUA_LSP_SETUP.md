# Lua Language Server Setup for Hyprland Config

Hyprland 0.55+ uses Lua for configuration. The `hl` global object is injected by the
Hyprland runtime and is not recognized by
[lua_ls](https://github.com/LuaLS/lua-language-server) out of the box, which causes
`Undefined global 'hl'` diagnostics in your editor.

Hyprland ships **official type stubs** (`hl.meta.lua`) that provide full LuaCATS
annotations for the `hl` API.

## Setup Steps

### 1. Create a symlink to the Hyprland stubs

From the **repository root**, run:

```bash
ln -sfn "$(dirname $(readlink -f $(which Hyprland)))/../share/hypr/stubs" .hypr-stubs
```

This creates a `.hypr-stubs` symlink pointing to the stubs directory inside the
Hyprland Nix store path (e.g. `/nix/store/<hash>-hyprland-0.55.2/share/hypr/stubs/`).

### 2. Create `.luarc.json` in the repository root

```json
{
  "$schema": "https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json",
  "workspace.library": [".hypr-stubs"]
}
```

This tells `lua_ls` to load the type definitions from the stubs directory. The stubs
file already declares `hl` as a global (`---@type HL.API`), so there is no need to
add `"diagnostics.globals": ["hl"]` separately.


## After Updating Hyprland

When you update Hyprland to a new version (e.g. via `nixos-rebuild switch`), the old
Nix store path may be garbage-collected and the symlink will break. Simply re-run the
symlink command from step 1:

```bash
ln -sfn "$(dirname $(readlink -f $(which Hyprland)))/../share/hypr/stubs" .hypr-stubs
```

## References

- [Hyprland Wiki – Lua Configuration](https://wiki.hypr.land/Configuring/)
- [LuaLS – Configuration File](https://luals.github.io/wiki/configuration/)
- [LuaLS – Settings (diagnostics.globals)](https://luals.github.io/wiki/settings/)
