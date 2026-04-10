# Hammerspoon

Hammerspoon Configuration for macOS automation

## Directory Structure

```shell
├── init.lua                Main configuration file
├── Spoons                  Official dependency packages
│   ├── ModalMgr.spoon      Modal dependency module
│   │   ├── docs.json
│   │   └── init.lua
│   └── WinWin.spoon        Window management dependency
│       ├── docs.json
│       └── init.lua
├── app_launcher            Application shortcuts
│   └── init.lua
├── clipboard               Clipboard history
│   └── init.lua
├── ime                     Input method auto-switch
│   └── init.lua
├── switch                  Multi-monitor window switching
│   └── init.lua
├── usb                     Record USB logs
│   └── init.lua
└── window                  Quick window management
    └── init.lua
```

## Installation

1. Install Hammerspoon from the [official website](https://www.hammerspoon.org/).
2. Copy the contents of this repository into your Hammerspoon configuration directory (`~/.hammerspoon/`).

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
