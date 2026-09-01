{
  pkgs,
  hostContext,
  ...
}: let
  screenshotBin = pkgs.writeShellScriptBin "screenshot" ''
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f -
  '';
in {
  home.packages = with pkgs; [
    screenshotBin
    # Screenshoot tools
    grim
    # snapshot editing tool
    swappy
    # Select a region tool
    slurp
  ];

  home.file.".config/swappy/config".text = ''
    [Default]
    save_dir="/home/${hostContext.username}/Pictures/Screenshots"
    save_filename_format=swappy-%Y%m%d-%H%M%S.png
    show_panel=false
    line_size=5
    text_size=20
    text_font="Noto Sans Regular"
    paint_mode=brush
    early_exit=true
    fill_shape=false
  '';
}
