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
      "xfce"
      "hyprland"
    ];
    default = "none";
    description = ''
      Which graphical session to enable. "none" is a headless machine.
      Add more DEs/compositors as extra enum values + mkIf branches.
    '';
  };

  config = lib.mkMerge [
    # ---- Shared desktop plumbing (any graphical environment) -------------
    (lib.mkIf (cfg.environment != "none") {
      security.polkit.enable = true;
      services.dbus.enable = true;
      programs.dconf.enable = true;
      services.gvfs.enable = true; # trash / mounts for file managers

      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };
    })

    # ---- XFCE (X11, lightweight, traditional desktop) -------------------
    (lib.mkIf (cfg.environment == "xfce") {
      services.xserver = {
        enable = true;
        xkb.layout = "us";
        desktopManager.xfce.enable = true;
        displayManager.lightdm.enable = true;
      };
      services.displayManager.defaultSession = "xfce";

      # A couple of quality-of-life extras XFCE users expect.
      environment.systemPackages = with pkgs; [
        xfce.xfce4-whiskermenu-plugin # nicer start menu
        xfce.xfce4-pulseaudio-plugin # volume control in the panel
        xfce.xfce4-screenshooter

        # Everyday apps (Thunar file manager already ships with XFCE)
        xfce.mousepad # simple text editor
        xfce.ristretto # image viewer
        xarchiver # archive manager (zip/tar/7z…)
        evince # PDF viewer
      ];
    })

    # ---- Hyprland (Wayland tiling compositor) ---------------------------
    (lib.mkIf (cfg.environment == "hyprland") {
      programs.hyprland.enable = true;

      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
          user = "greeter";
        };
      };

      environment.sessionVariables.NIXOS_OZONE_WL = "1";
      environment.systemPackages = [ pkgs.tuigreet ];
    })
  ];
}
