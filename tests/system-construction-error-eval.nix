let
  caseName = builtins.getEnv "SYSTEM_CONSTRUCTION_ERROR_CASE";
  inputs = (builtins.getFlake (toString ../.)).inputs;
  constructInventory = import ../lib/system-construction.nix {inherit inputs;};
  outputs = constructInventory (./fixtures/system-construction/validation + "/${caseName}");
  platformMismatch = constructInventory ./fixtures/system-construction/platform-mismatch;
in
  if caseName == "platform-mismatch"
  then platformMismatch.nixosConfigurations.linux-host.config.system.build.toplevel.drvPath
  else if
    builtins.elem caseName [
      "declaration-not-attributes"
      "declaration-unknown-field"
      "missing-declaration"
    ]
  then builtins.deepSeq outputs.inventory true
  else throw "Unknown system-construction error test case: ${caseName}"
