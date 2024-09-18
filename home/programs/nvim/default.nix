{ pkgs, pkgs-unstable, ... }: {
  programs.neovim = {
    enable = true;
    package = pkgs-unstable.neovim-unwrapped;

    viAlias = true;

    plugins = [ ];
    withNodeJs = true;
    withPython3 = true;
    extraPython3Packages = pyPkgs: with pyPkgs; [ ];

    # These environment variables are needed to build and run binaries
    # with external package managers like mason.nvim.
    #
    extraWrapperArgs = with pkgs; [
      # LIBRARY_PATH is used by gcc before compilation to search directories
      # containing static and shared libraries that need to be linked to your program.
      "--suffix"
      "LIBRARY_PATH"
      ":"
      "${lib.makeLibraryPath [
        stdenv.cc.cc
        zlib
        fontconfig
        freetype
      ]}" # NOTE: fontconfig and freetype for plugin `silicon.nvim`

      # PKG_CONFIG_PATH is used by pkg-config before compilation to search directories
      # containing .pc files that describe the libraries that need to be linked to your program.
      "--suffix"
      "PKG_CONFIG_PATH"
      ":"
      "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
        stdenv.cc.cc
        zlib
        fontconfig
        freetype
      ]}"

      # LD_LIBRARY_PATH is also needed to run the non-FHS binaries downloaded by mason.nvim or plugin
      # WARN: nix-ld can set it also add this only for `silicon.nvim` plugin
      "--suffix"
      "LD_LIBRARY_PATH"
      ":"
      "${lib.makeLibraryPath [ stdenv.cc.cc zlib fontconfig freetype ]}"
    ];
  };

  home.packages = with pkgs; [ python311Packages.pynvim ];
}
