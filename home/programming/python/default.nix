{
  lib,
  pkgs,
  ...
}: let
  llmWtihPlugins = pkgs.llm.withPlugins {
    # LLM plugin to access Google's Gemini family of models <https://github.com/simonw/llm-gemini>
    llm-gemini = true;
  };
in {
  # Python
  home.packages = with pkgs; [
    (python313.withPackages (pyPkgs: with pyPkgs; [requests]))

    # view csv xls in terminal
    visidata
    # CLI tool interacting with AI
    llmWtihPlugins
    # run python applications in isolated environments
    pipx
  ];

  imports = [
    ./poetry.nix # Python dependency management
    ./uv.nix # Python dependency management, written in Rust, so fast
  ];
}
