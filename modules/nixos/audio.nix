{ lib, config, ... }:
let
  cfg = config.cak.audio;
in
{
  options.cak.audio.enable = lib.mkEnableOption "PipeWire audio stack" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
