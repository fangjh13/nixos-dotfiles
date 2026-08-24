{inputs}: hostsPath: let
  inherit (inputs.nixpkgs) lib;

  supportedSystems = import ./supported-systems.nix;

  fail = name: message: throw "Host `${name}`: ${message}";
  hostPath = name: hostsPath + "/${name}";
  declarationPath = name: hostPath name + "/host.nix";
  settingsPath = name: hostPath name + "/variables.nix";
  configurationPath = name: hostPath name + "/default.nix";

  requireFile = name: description: path:
    if builtins.pathExists path
    then path
    else fail name "missing ${description}";

  requireString = name: field: value:
    if builtins.isString value && value != ""
    then value
    else fail name "`${field}` must be a non-empty string";

  requireCleanString = name: field: value: let
    stringValue = requireString name field value;
  in
    if lib.strings.trim stringValue == stringValue
    then stringValue
    else fail name "`${field}` must not contain leading or trailing whitespace";

  requireStringList = name: field: value:
    if builtins.isList value && builtins.all builtins.isString value
    then value
    else fail name "`${field}` must be a list of strings";

  requireStringValue = name: field: value:
    if builtins.isString value
    then value
    else fail name "`${field}` must be a string";

  requireOptionalString = name: field: value:
    if value == null || builtins.isString value
    then value
    else fail name "`${field}` must be null or a string";

  normalizeSettings = name: platform: settings: let
    gitName = requireCleanString name "settings.gitName" (settings.gitName or null);
    gitEmail = requireCleanString name "settings.gitEmail" (settings.gitEmail or null);
    timezone = requireCleanString name "settings.timezone" (settings.timezone or null);
    platformSettings =
      if platform == "linux"
      then {
        useGUI =
          if builtins.isBool (settings.useGUI or null)
          then settings.useGUI
          else fail name "`settings.useGUI` must be a boolean for Linux hosts";
        apps = requireStringList name "settings.apps" (settings.apps or []);
        bookmarks = requireStringList name "settings.bookmarks" (settings.bookmarks or []);
        hyprConfig = requireStringValue name "settings.hyprConfig" (settings.hyprConfig or "");
        xkbOptions = requireStringValue name "settings.xkbOptions" (settings.xkbOptions or "");
        wallpaper = requireOptionalString name "settings.wallpaper" (settings.wallpaper or null);
      }
      else {
        brews = requireStringList name "settings.brews" (settings.brews or []);
        casks = requireStringList name "settings.casks" (settings.casks or []);
      };
  in
    settings
    // {
      inherit gitName gitEmail timezone;
    }
    // platformSettings;

  validateHost = name: let
    safeName = builtins.match "^[A-Za-z0-9][A-Za-z0-9._-]*$" name != null;
    importedDeclaration = import (requireFile name "Host declaration" (declarationPath name));
    declaration =
      if builtins.isAttrs importedDeclaration
      then importedDeclaration
      else fail name "Host declaration must evaluate to an attribute set";
    declarationFields = builtins.attrNames declaration;
    expectedFields = ["system" "username"];
    exactFields = declarationFields == expectedFields;
    system = requireString name "system" (declaration.system or null);
    username = requireCleanString name "username" (declaration.username or null);
    supported = builtins.elem system supportedSystems;
    platform =
      if lib.hasSuffix "-linux" system
      then "linux"
      else if lib.hasSuffix "-darwin" system
      then "darwin"
      else fail name "cannot derive a platform from system `${system}`";
    importedSettings = import (requireFile name "settings" (settingsPath name));
    rawSettings =
      if builtins.isAttrs importedSettings
      then importedSettings
      else fail name "settings must evaluate to an attribute set";
    settings = normalizeSettings name platform rawSettings;
    module = requireFile name "configuration" (configurationPath name);
  in
    if !safeName
    then fail name "directory name contains unsupported characters"
    else if !exactFields
    then fail name "Host declaration fields must be exactly `system` and `username`; found `${lib.concatStringsSep "`, `" declarationFields}`"
    else if !supported
    then fail name "system `${system}` is not supported"
    else {
      inherit name system username platform settings module;
    };

  directoryEntries = builtins.readDir hostsPath;
  templatesPath = hostsPath + "/templates";
  templateEntries =
    if builtins.pathExists templatesPath
    then builtins.readDir templatesPath
    else {};
  templateNames = builtins.filter (
    name: templateEntries.${name} == "directory"
  ) (builtins.attrNames templateEntries);
  templatesWithDeclarations =
    builtins.filter (
      name: builtins.pathExists (templatesPath + "/${name}/host.nix")
    )
    templateNames;
  validatedTemplates =
    if templatesWithDeclarations == []
    then true
    else throw "Host template `${builtins.head templatesWithDeclarations}` must not contain a Host declaration";
  hostNames = builtins.filter (
    name:
      name
      != "templates"
      && directoryEntries.${name} == "directory"
  ) (builtins.attrNames directoryEntries);

  inventory = builtins.seq validatedTemplates (lib.genAttrs hostNames validateHost);
  linuxInventory = lib.filterAttrs (_: host: host.platform == "linux") inventory;
  darwinInventory = lib.filterAttrs (_: host: host.platform == "darwin") inventory;

  mkPackageSets = system: {
    stable = import inputs.nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };
    unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };

  mkConfiguration = host: let
    isLinux = host.platform == "linux";
    packageSets = mkPackageSets host.system;
    hostContext = {
      inherit (host) name system username platform settings;
    };
    systemFunction =
      if isLinux
      then inputs.nixpkgs.lib.nixosSystem
      else inputs.nix-darwin.lib.darwinSystem;
    homeManagerModules =
      if isLinux
      then inputs.home-manager.nixosModules
      else inputs.home-manager.darwinModules;
    sopsModule =
      if isLinux
      then inputs.sops-nix.nixosModules.sops
      else inputs.sops-nix.darwinModules.sops;
    userModule =
      if isLinux
      then ../modules/nixos/users.nix
      else ../modules/darwin/users.nix;
    homeManagerModule =
      if isLinux
      then ../modules/nixos/homemanager
      else ../modules/darwin/homemanager;
  in
    systemFunction {
      system =
        if isLinux
        then null
        else host.system;
      specialArgs = {inherit hostContext packageSets inputs;};
      modules =
        [
          (lib.optionalAttrs (!isLinux) {nixpkgs.hostPlatform = host.system;})
          sopsModule
          ../modules/public/sops.nix
          ../modules/public/secrets/llm
          (
            if isLinux && host.settings.useGUI
            then inputs.catppuccin.nixosModules.catppuccin
            else {}
          )
          ../modules/public/services/frpc.nix
          ../modules/public/services/sing-box.nix
          ../modules/public/services/mihomo.nix
        ]
        ++ lib.optionals isLinux [
          ../modules/nixos/system.nix
          ../modules/nixos/options
        ]
        ++ lib.optionals (!isLinux) [
          ../modules/darwin/system.nix
          ../modules/darwin/hammerspoon
          ../modules/darwin/karabiner-elements
          ../modules/darwin/input-method.nix
        ]
        ++ [
          ../modules/public/options/ghostty.nix
          host.module
          userModule
          homeManagerModules.home-manager
          homeManagerModule
          ({config, ...}: {
            assertions = lib.optional isLinux {
              assertion = config.nixpkgs.hostPlatform.system == host.system;
              message = "Host `${host.name}`: declared system `${host.system}` does not match the evaluated host platform `${config.nixpkgs.hostPlatform.system}`";
            };
          })
        ];
    };

  nixosConfigurations = lib.mapAttrs (_: mkConfiguration) linuxInventory;
  darwinConfigurations = lib.mapAttrs (_: mkConfiguration) darwinInventory;

  checks = lib.genAttrs supportedSystems (system: let
    pkgs = import inputs.nixpkgs {inherit system;};
    configurationFor = host:
      if host.platform == "linux"
      then nixosConfigurations.${host.name}
      else darwinConfigurations.${host.name};
    inventorySummary =
      lib.mapAttrsToList (_: host: let
        configuration = configurationFor host;
      in {
        inherit (host) name system platform username settings;
        evaluatedSystem = configuration.config.nixpkgs.hostPlatform.system;
        stateVersion = configuration.config.system.stateVersion;
      })
      inventory;
    systemPaths = lib.mapAttrsToList (_: host:
      (configurationFor host).config.system.build.toplevel.drvPath)
    inventory;
  in {
    host-inventory-evaluation = builtins.deepSeq [inventorySummary systemPaths] (pkgs.runCommand "host-inventory-evaluation" {} ''
      touch "$out"
    '');
  });
in {
  inherit inventory nixosConfigurations darwinConfigurations checks;
}
