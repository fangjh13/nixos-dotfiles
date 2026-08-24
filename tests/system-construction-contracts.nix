{inputs}: let
  constructInventory = import ../lib/system-construction.nix {inherit inputs;};
  valid = constructInventory ./fixtures/system-construction/valid;
  invalidSettings = constructInventory ./fixtures/system-construction/invalid-settings;
  templateDeclaration = constructInventory ./fixtures/system-construction/template-declaration;
  platformMismatch = constructInventory ./fixtures/system-construction/platform-mismatch;
  validationMatrix = import ./system-construction-validation.nix {inherit inputs;};

  invalidSettingsFails = !(builtins.tryEval (builtins.deepSeq invalidSettings.inventory true)).success;
  templateDeclarationFails = !(builtins.tryEval (builtins.deepSeq templateDeclaration.inventory true)).success;
  platformMismatchFails = !(builtins.tryEval platformMismatch.nixosConfigurations.linux-host.config.system.build.toplevel.drvPath).success;
  linuxHosts = builtins.attrNames valid.nixosConfigurations;
  darwinHosts = builtins.attrNames valid.darwinConfigurations;
  armDefaults = valid.inventory.arm-linux-host.settings;
  darwinDefaults = valid.inventory.darwin-host.settings;
  buildPaths = [
    valid.nixosConfigurations.arm-linux-host.config.system.build.toplevel.drvPath
    valid.nixosConfigurations.linux-host.config.system.build.toplevel.drvPath
    valid.nixosConfigurations.second-linux-host.config.system.build.toplevel.drvPath
    valid.darwinConfigurations.darwin-host.config.system.build.toplevel.drvPath
  ];
in
  assert validationMatrix;
  assert invalidSettingsFails;
  assert templateDeclarationFails;
  assert platformMismatchFails;
  assert linuxHosts == ["arm-linux-host" "linux-host" "second-linux-host"];
  assert darwinHosts == ["darwin-host"];
  assert armDefaults.apps == [];
  assert armDefaults.bookmarks == [];
  assert armDefaults.hyprConfig == "";
  assert armDefaults.xkbOptions == "";
  assert armDefaults.wallpaper == null;
  assert darwinDefaults.brews == [];
  assert darwinDefaults.casks == [];
  builtins.deepSeq buildPaths true
