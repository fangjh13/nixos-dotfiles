{
  lib,
  pkgs,
  ...
}: let
  llmWithPlugins = pkgs.python313Packages.llm.withPlugins {
    # LLM plugin to access Google's Gemini family of models <https://github.com/simonw/llm-gemini>
    llm-gemini = true;
  };
in {
  # Python
  home.packages = with pkgs; [
    (python313.withPackages (pyPkgs: with pyPkgs; [requests]))

    # CLI tool interacting with AI
    llmWithPlugins

    # Command Line Interface to FreeDesktop.org Trash
    trash-cli
  ];

  imports = [
    ./poetry.nix # Python dependency management
    ./uv.nix # Python dependency management, written in Rust, so fast
  ];
}
