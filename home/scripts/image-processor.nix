{pkgs}: let
  # Define a name and path for the script
  script-name = "image-processor";
  src = builtins.readFile ./image-processor/image-processor.sh;
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
  }
