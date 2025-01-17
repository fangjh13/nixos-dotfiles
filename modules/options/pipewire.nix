# https://wiki.nixos.org/wiki/PipeWire
{ lib, pkgs, config, ... }:
with lib;
let cfg = config.multimedia.pipewire;
in {
  options.multimedia.pipewire = {
    enable = mkEnableOption "Enable PipeWire multimedia framework";
  };

  config = mkIf cfg.enable {
    # enable the RealtimeKit system service, which hands out realtime scheduling priority to user processes on demand. For example, PulseAudio and PipeWire use this to acquire realtime priority.
    security.rtkit.enable = true;
    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        # jack.enable = true;
      };
    };
  };
}

