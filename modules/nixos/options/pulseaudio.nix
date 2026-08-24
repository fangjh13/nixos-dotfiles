# https://wiki.nixos.org/wiki/PulseAudio
{
  lib,
  hostContext,
  config,
  ...
}:
with lib; let
  inherit (hostContext) username;
  cfg = config.multimedia.pulseaudio;
in {
  options.multimedia.pulseaudio = {
    enable = mkEnableOption "Enable Pulseaudio";
  };

  config = mkIf cfg.enable {
    services.pipewire.enable = false;
    services.pulseaudio = {
      enable = true;
      # If compatibility with 32-bit applications is desired.
      support32Bit = true;
    };
    users.users."${username}".extraGroups = ["audio"];
  };
}
