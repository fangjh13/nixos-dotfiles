{inputs}: let
  inherit (inputs.nixpkgs) lib;
  constructInventory = import ../lib/system-construction.nix {inherit inputs;};
  valid = constructInventory ./fixtures/system-construction/valid;
  templateDeclaration = constructInventory ./fixtures/system-construction/template-declaration;
  platformMismatch = constructInventory ./fixtures/system-construction/platform-mismatch;
  desktopMissingTerminal = constructInventory ./fixtures/system-construction/desktop-missing-terminal;
  desktopInvalidTerminal = constructInventory ./fixtures/system-construction/desktop-invalid-terminal;
  desktopInvalidMonitor = constructInventory ./fixtures/system-construction/desktop-invalid-monitor;
  desktopOverrides = constructInventory ./fixtures/system-construction/desktop-overrides;
  terminalSelections = constructInventory ./fixtures/system-construction/terminal-selections;
  validationMatrix = import ./system-construction-validation.nix {inherit inputs;};

  templateDeclarationFails = !(builtins.tryEval (builtins.deepSeq templateDeclaration.inventory true)).success;
  platformMismatchFails = !(builtins.tryEval platformMismatch.nixosConfigurations.linux-host.config.system.build.toplevel.drvPath).success;
  desktopMissingTerminalFails = !(builtins.tryEval desktopMissingTerminal.nixosConfigurations.missing-terminal.config.system.build.toplevel.drvPath).success;
  desktopInvalidTerminalFails = !(builtins.tryEval desktopInvalidTerminal.nixosConfigurations.invalid-terminal.config.system.build.toplevel.drvPath).success;
  desktopInvalidMonitorFails = !(builtins.tryEval desktopInvalidMonitor.nixosConfigurations.invalid-monitor.config.system.build.toplevel.drvPath).success;
  desktopOverrideConfig = desktopOverrides.nixosConfigurations.desktop-overrides.config;
  linuxHosts = builtins.attrNames valid.nixosConfigurations;
  darwinHosts = builtins.attrNames valid.darwinConfigurations;
  inventoryFields = builtins.attrNames valid.inventory.native-linux-host;
  baselineConfig = valid.nixosConfigurations.native-linux-host.config;
  baselineHome = baselineConfig.home-manager.users.tester;
  baselineOverrideConfig = valid.nixosConfigurations.second-linux-host.config;
  desktopConfig = valid.nixosConfigurations.desktop-linux-host.config;
  desktopHome = desktopConfig.home-manager.users.tester;
  desktopHyprlandLua = desktopHome.wayland.windowManager.hyprland.extraLuaFiles.config.content;
  desktopWaybar = builtins.head desktopHome.programs.waybar.settings;
  terminalExpectations = {
    ghostty = {
      command = "ghostty";
      execute = "ghostty -e nvim %F";
      floating = "ghostty --title=FloatWindow -e btop";
    };
    kitty = {
      command = "kitty";
      execute = "kitty --execute nvim %F";
      floating = "kitty -T FloatWindow --execute btop";
    };
    alacritty = {
      command = "alacritty";
      execute = "alacritty -e nvim %F";
      floating = "alacritty --title FloatWindow -e btop";
    };
    wezterm = {
      command = "wezterm start";
      execute = "wezterm start -- nvim %F";
      floating = "wezterm start --class FloatWindow -- btop";
    };
  };
  terminalSelectionWorks = name: expected: let
    home = terminalSelections.nixosConfigurations.${name}.config.home-manager.users.tester;
    hyprlandLua = home.wayland.windowManager.hyprland.extraLuaFiles.config.content;
    waybar = builtins.head home.programs.waybar.settings;
  in
    home.programs.${name}.enable
    && lib.hasInfix ''local terminal = "${expected.command}"'' hyprlandLua
    && waybar."custom/cputemp".on-click == expected.floating
    && home.xdg.desktopEntries.neovim.exec == expected.execute;
  terminalSelectionsWork = lib.mapAttrsToList terminalSelectionWorks terminalExpectations;
  buildPaths = map builtins.unsafeDiscardStringContext [
    valid.nixosConfigurations.arm-linux-host.config.system.build.toplevel.drvPath
    valid.nixosConfigurations.desktop-linux-host.config.system.build.toplevel.drvPath
    valid.nixosConfigurations.linux-host.config.system.build.toplevel.drvPath
    valid.nixosConfigurations.native-linux-host.config.system.build.toplevel.drvPath
    valid.nixosConfigurations.second-linux-host.config.system.build.toplevel.drvPath
    valid.darwinConfigurations.darwin-host.config.system.build.toplevel.drvPath
  ];
in
  assert validationMatrix;
  assert templateDeclarationFails;
  assert platformMismatchFails;
  assert desktopMissingTerminalFails;
  assert desktopInvalidTerminalFails;
  assert desktopInvalidMonitorFails;
  assert linuxHosts == ["arm-linux-host" "desktop-linux-host" "linux-host" "native-linux-host" "second-linux-host"];
  assert darwinHosts == ["darwin-host"];
  assert inventoryFields == ["module" "name" "platform" "system" "username"];
  assert baselineConfig.networking.hostName == "native-linux-host";
  assert !baselineConfig.catppuccin.enable;
  assert !baselineHome.catppuccin.enable;
  assert baselineConfig.boot.loader.systemd-boot.enable;
  assert baselineConfig.boot.loader.efi.canTouchEfiVariables;
  assert baselineConfig.boot.plymouth.enable;
  assert baselineConfig.networking.networkmanager.enable;
  assert !baselineOverrideConfig.boot.loader.systemd-boot.enable;
  assert !baselineOverrideConfig.boot.loader.efi.canTouchEfiVariables;
  assert !baselineOverrideConfig.boot.plymouth.enable;
  assert !baselineOverrideConfig.networking.networkmanager.enable;
  assert !desktopOverrideConfig.hardware.bluetooth.enable;
  assert !desktopOverrideConfig.services.blueman.enable;
  assert desktopConfig.profiles.desktop.enable;
  assert desktopConfig.catppuccin.enable;
  assert desktopHome.catppuccin.enable;
  assert desktopConfig.multimedia.pipewire.enable;
  assert desktopConfig.hardware.bluetooth.enable;
  assert desktopConfig.services.greetd.enable;
  assert desktopHome.programs.waybar.enable;
  assert desktopHome.programs.wezterm.enable;
  assert desktopHome.programs.kitty.enable;
  assert desktopHome.programs.ghostty.enable;
  assert desktopHome.wayland.windowManager.hyprland.enable;
  assert lib.hasInfix ''hl.monitor({ output = "Virtual-1", mode = "1920x1080@60", position = "auto", scale = 1.000000 })'' desktopHyprlandLua;
  assert lib.hasInfix ''kb_options = "ctrl:nocaps,altwin:swap_lalt_lwin"'' desktopHyprlandLua;
  assert lib.hasInfix ''hl.env("PROFILE_TEST", "enabled")'' desktopHyprlandLua;
  assert lib.hasInfix ''hl.env("PROFILE_EXTRA_LUA", "enabled")'' desktopHyprlandLua;
  assert lib.hasInfix ''local terminal = "wezterm start"'' desktopHyprlandLua;
  assert lib.hasInfix ''match = { class = "^(FloatWindow)$" }'' desktopHyprlandLua;
  assert desktopWaybar."custom/cputemp".on-click == "wezterm start --class FloatWindow -- btop";
  assert desktopHome.xdg.desktopEntries.neovim.exec == "wezterm start -- nvim %F";
  assert builtins.all (value: value) terminalSelectionsWork;
    builtins.deepSeq buildPaths true
