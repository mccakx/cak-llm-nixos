{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.cak.remote;

  # Launch XFCE inside its own D-Bus session. Without this, an RDP login
  # collides with a console login of the same user (xfce4-session is
  # single-instance per bus) and the session dies instantly -> blank screen.
  xrdpXfceSession = pkgs.writeShellScript "xrdp-xfce-session" ''
    export XDG_SESSION_TYPE=x11
    export XDG_CURRENT_DESKTOP=XFCE
    exec ${pkgs.dbus}/bin/dbus-run-session -- ${pkgs.xfce.xfce4-session}/bin/xfce4-session
  '';
in
{
  # Remote-access toggles. Off by default.
  options.cak.remote = {
    rdp.enable =
      lib.mkEnableOption "xrdp remote desktop (RDP on TCP 3389, connect with Remmina)";

    idleLogoutMinutes = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = ''
        Auto-logout any login session idle longer than this many minutes
        (0 = never). Prevents a forgotten console login from blocking an
        RDP login of the same user. Applies to all sessions incl. RDP.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.rdp.enable {
      services.xrdp = {
        enable = true;
        openFirewall = true; # opens TCP 3389
        defaultWindowManager = "${xrdpXfceSession}";
      };
      # xrdp auto-generates a self-signed TLS cert on first start.
    })

    (lib.mkIf (cfg.idleLogoutMinutes > 0) {
      services.logind.settings.Login.StopIdleSessionSec = cfg.idleLogoutMinutes * 60;
    })
  ];
}
