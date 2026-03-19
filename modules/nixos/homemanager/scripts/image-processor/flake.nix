{
  description = "image-processor script wrapper";

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f system {
          pkgs = import nixpkgs {inherit system;};
        });
  in {
    packages = forEachSupportedSystem (system: {pkgs}: {
      default = let
        # Define a name and path for the script
        script-name = "image-processor";
        src = builtins.readFile ./image-processor.sh;
        script = (pkgs.writeScriptBin script-name src).overrideAttrs (old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
        # Script dependencies
        buildInputs = with pkgs; [imagemagick];
      in
        pkgs.symlinkJoin {
          name = script-name;
          paths = [script] ++ buildInputs;
          buildInputs = [pkgs.makeWrapper];
          postBuild = "wrapProgram $out/bin/${script-name} --prefix PATH : $out/bin";
        };
    });
  };
}
