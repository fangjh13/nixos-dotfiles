{inputs}: let
  constructInventory = import ../lib/system-construction.nix {inherit inputs;};
  fixtureRoot = ./fixtures/system-construction/validation;
  invalidCases = [
    "missing-declaration"
    "unsafe-name"
    "declaration-not-attributes"
    "declaration-unknown-field"
    "declaration-missing-system"
    "declaration-missing-username"
    "declaration-empty-username"
    "declaration-wrong-system-type"
    "declaration-unsupported-system"
    "settings-not-attributes"
    "settings-missing-common"
    "settings-git-whitespace"
    "settings-linux-use-gui-type"
    "settings-linux-apps-type"
    "settings-darwin-brews-type"
  ];
  caseFails = caseName: let
    outputs = constructInventory (fixtureRoot + "/${caseName}");
  in
    !(builtins.tryEval (builtins.deepSeq outputs.inventory true)).success;
in
  assert builtins.all caseFails invalidCases;
  true
