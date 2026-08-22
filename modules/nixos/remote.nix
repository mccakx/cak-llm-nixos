{ lib, config, ... }:
let
  cfg = config.cak.remote;
in
{
  # Remote-access toggles. Off by default.
  options.cak.remote.rdp.enable =
    lib.mkEnableOption "xrdp remote desktop (RDP on TCP 3389, connect with Remmina)";

  config = lib.mkIf cfg.rdp.enable {
    services.xrdp = {
      enable = true;
      openFirewall = true; # opens TCP 3389
      # The desktop session xrdp launches on connect. Matches the XFCE host.
      defaultWindowManager = "startxfce4";
    };
    # xrdp auto-generates a self-signed TLS cert on first start.
  };
}
