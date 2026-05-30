{
  lib,
  pkgs,
  ...
}: let
  llmWithPlugins = pkgs.python314Packages.llm.withPlugins {
    # LLM plugin to access Google's Gemini family of models <https://github.com/simonw/llm-gemini>
    llm-gemini = true;
  };
in {
  # Python
  home.packages = with pkgs; [
    # Python 3.14 with some commonly used packages
    (python314.withPackages (pyPkgs: with pyPkgs; [requests]))

    # CLI tool interacting with AI
    llmWithPlugins
  ];

  imports = [
    ./poetry.nix # Python dependency management
    ./uv.nix # Python dependency management, written in Rust, so fast
  ];
}
