{ lib, config, ... }:
let
  cfg = config.cak.virtualisation;
in
{
  # Off by default (keeps the base image lightweight). Flip on per host
  # when you want containers or VMs on that machine.
  options.cak.virtualisation = {
    podman.enable = lib.mkEnableOption "Podman (with docker CLI compat)";
    libvirt.enable = lib.mkEnableOption "libvirt/QEMU + virt-manager";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.podman.enable {
      virtualisation.containers.enable = true;
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    })
    (lib.mkIf cfg.libvirt.enable {
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;
    })
  ];
}
