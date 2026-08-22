{ lib, config, ... }:
let
  cfg = config.cak.gaming;
in
{
  # Off by default. A future bare-metal host can just set
  # `cak.gaming.enable = true;` to pull in the whole stack.
  options.cak.gaming.enable = lib.mkEnableOption "Steam + gamemode + gamescope";

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      gamescopeSession.enable = true;
    };
    programs.gamemode.enable = true;
    programs.gamescope.enable = true;
  };
}
