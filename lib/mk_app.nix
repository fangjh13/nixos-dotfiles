# A fuction to create flake apps
{
  nixpkgs,
  self,
}: scriptName: arch: {
  type = "app";
  program = "${(nixpkgs.legacyPackages.${arch}.writeScriptBin scriptName ''
    #!/usr/bin/env bash
    echo "🔧 Running ${scriptName} script. Your architecture is ${arch}.";
    exec ${self}/modules/scripts/app/${arch}/${scriptName} "$@"
  '')}/bin/${scriptName}";
}
