{inputs}: system: let
  inherit (inputs.nixpkgs) lib;
  supportedSystems = import ./supported-systems.nix;
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  onboarding = pkgs.writeShellApplication {
    name = "inventory-onboarding";
    runtimeInputs =
      [
        pkgs.coreutils
        pkgs.git
        pkgs.gnugrep
        pkgs.gnused
        pkgs.nix
      ]
      ++ lib.optionals (lib.hasSuffix "-linux" system) [
        pkgs.nixos-install-tools
      ];
    text = builtins.readFile ../modules/scripts/inventory-onboarding.sh;
  };
in
  if builtins.elem system supportedSystems
  then {
    type = "app";
    program = "${onboarding}/bin/inventory-onboarding";
    meta.description = "Interactively register the current machine in the Host inventory";
  }
  else throw "Inventory onboarding does not support system `${system}`"
