{ lib, config, ... }:
let
  cfg = config.cak.home.browser;
in
{
  options.cak.home.browser.firefox.enable =
    lib.mkEnableOption "Firefox" // { default = true; };

  config = lib.mkIf cfg.firefox.enable {
    programs.firefox = {
      enable = true;
      # Sensible defaults; extend policies/profiles here later.
      profiles.default = {
        settings = {
          "widget.use-xdg-desktop-portal.file-picker" = 1;
        };
      };
    };
  };
}
