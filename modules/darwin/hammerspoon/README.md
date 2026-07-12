# Hammerspoon module

Installs Hammerspoon and deploys its macOS automation configuration with nix-darwin and Home Manager.

## Directory Structure

```shell
├── default.nix             nix-darwin module
└── config                  Hammerspoon configuration deployed to ~/.hammerspoon
    ├── init.lua            Main configuration file
    ├── Spoons              Official dependency packages
    ├── app_launcher        Application shortcuts
    ├── clipboard           Clipboard history
    ├── ime                 Input method auto-switch
    ├── switch              Multi-monitor window switching
    ├── usb                 Record USB logs
    └── window              Quick window management
```

## Installation

Enable the module in the Darwin host configuration:

```nix
addon.hammerspoon.enable = true;
```

The module installs the `hammerspoon` Homebrew cask and recursively deploys `config/` to `~/.hammerspoon/`.

## Setting Up [EmmyLua](https://www.hammerspoon.org/Spoons/EmmyLua.html)

When editing Hammerspoon configuration files (`.lua`) with a Lua language server (`lua_ls`), you may encounter warnings like:

```
Undefined global `hs`
```

This happens because `lua_ls` does not know about Hammerspoon's global `hs` object. The official [EmmyLua.spoon](https://github.com/Hammerspoon/Spoons/tree/master/Source/EmmyLua.spoon) plugin solves this by generating type annotation stubs from the Hammerspoon API, giving you **full autocompletion, function signatures, hover documentation, and type checking** — not just silencing the warning.

### Step 1: Install EmmyLua.spoon

Download and extract the Spoon into your Hammerspoon Spoons directory:

```bash
curl -L -o /tmp/EmmyLua.spoon.zip \
  https://github.com/Hammerspoon/Spoons/raw/master/Spoons/EmmyLua.spoon.zip

unzip -o /tmp/EmmyLua.spoon.zip -d ~/.hammerspoon/Spoons/
```

### Step 2: Load the Spoon in Hammerspoon

Add the following line to the **very top** of your `~/.hammerspoon/init.lua`, before any `hs.pathwatcher` definitions (to avoid unintended reloads when annotation files are generated):

```lua
hs.loadSpoon("EmmyLua")
```

Then reload your Hammerspoon configuration (menu bar → **Reload Config**, or run `hs.reload()` in the Hammerspoon console).

This triggers the Spoon to scan the Hammerspoon API and generate EmmyLua annotation files under:

```
~/.hammerspoon/Spoons/EmmyLua.spoon/annotations/
```

You should see files like `hs.lua`, `hs.application.lua`, `hs.window.lua`, etc.

### Step 3: Configure lua_ls

Create a `.luarc.json` file in your Hammerspoon config directory (`~/.hammerspoon/`):

```json
{
  "runtime": {
    "version": "Lua 5.4"
  },
  "diagnostics": {
    "globals": ["hs", "spoon"]
  },
  "workspace": {
    "library": [
      "/Users/YOUR_USERNAME/.hammerspoon/Spoons/EmmyLua.spoon/annotations"
    ],
    "checkThirdParty": false
  }
}
```
> Replace `YOUR_USERNAME` with your actual macOS username. The `~` shorthand may not be expanded by all `lua_ls` versions, so using an absolute path is recommended.
