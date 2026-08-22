{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.cak.desktop;
in
{
  options.cak.desktop.environment = lib.mkOption {
    type = lib.types.enum [
      "none"
      "hyprland"
    ];
    default = "none";
    description = ''
      Which graphical session to enable. "none" is a headless machine.
      Add more compositors/DEs as extra enum values + mkIf branches.
    '';
  };

  config = lib.mkIf (cfg.environment == "hyprland") {
    # Compositor (system side). The user session is configured in
    # Home Manager (modules/home/hyprland.nix).
    programs.hyprland.enable = true;

    # Minimal, light greeter that logs straight into Hyprland.
    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };

    # Desktop plumbing.
    security.polkit.enable = true;
    services.dbus.enable = true;
    programs.dconf.enable = true;
    services.gvfs.enable = true; # trash / mounts for the file manager

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # Wayland-friendly defaults.
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1"; # Electron/Chromium/Firefox run natively on Wayland
    };

    # A couple of system-level GUI bits everyone expects.
    environment.systemPackages = with pkgs; [
      greetd.tuigreet
    ];
  };
}
