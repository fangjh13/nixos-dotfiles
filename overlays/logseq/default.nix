_final: prev:
prev.lib.optionalAttrs (prev.stdenv.hostPlatform.system == "x86_64-linux") {
  logseq = prev.callPackage ./package.nix {};
}
