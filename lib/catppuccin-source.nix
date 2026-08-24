{inputs}: port: let
  sourceMetadata = (builtins.fromJSON (builtins.readFile (inputs.catppuccin + "/pkgs/sources.json"))).${port};
in
  (builtins.fetchTree {
    type = "github";
    owner = "catppuccin";
    repo = port;
    inherit (sourceMetadata) rev;
    narHash = sourceMetadata.hash;
  }).outPath
