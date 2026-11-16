{
  lib,
  rustPlatform,
  makeWrapper,
  _7zz-rar,
}:
rustPlatform.buildRustPackage {
  pname = "zippity";
  version = "0.0.6";

  # Keep upstream TOML readable during evaluation without building a fetcher.
  src = builtins.fetchTree {
    type = "github";
    owner = "hawkff";
    repo = "zippity";
    rev = "aec10be89f1468ba2b91f87d0d8dec298a86356e";
    narHash = "sha256-Neq+6bmWmL/x324vwv3g3TKY4ETA1Ivk/YQg2DPPPbw=";
  };

  cargoHash = "sha256-as/N7cEZ903xV9v8kB5lH4aPX7Y4dzzGqFddKADwCv8=";

  nativeBuildInputs = [makeWrapper];
  nativeCheckInputs = [_7zz-rar];

  postInstall = ''
    mkdir -p "$out/share/yazi/plugins/zippity.yazi"
    cp -R zippity.yazi/. "$out/share/yazi/plugins/zippity.yazi/"
    wrapProgram "$out/bin/zippity" \
      --prefix PATH : ${lib.makeBinPath [_7zz-rar]}
  '';

  meta = {
    description = "Browse, preview, and extract archives in Yazi without FUSE";
    homepage = "https://github.com/hawkff/zippity";
    license = lib.licenses.mit;
    mainProgram = "zippity";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
