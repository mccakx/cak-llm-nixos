{ lib, config, ... }:
let
  cfg = config.cak.guest;
in
{
  # Selects which hypervisor guest-integration to enable (display auto-resize,
  # shared clipboard, drivers). Set to "none" on bare metal.
  options.cak.guest.hypervisor = lib.mkOption {
    type = lib.types.enum [
      "none"
      "qemu"
      "virtualbox"
      "vmware"
      "hyperv"
    ];
    default = "none";
    description = "Guest tooling for the hypervisor this machine runs under.";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.hypervisor == "qemu") {
      services.qemuGuest.enable = true;
      services.spice-vdagentd.enable = true; # clipboard + auto display resize
    })
    (lib.mkIf (cfg.hypervisor == "virtualbox") {
      virtualisation.virtualbox.guest.enable = true;
    })
    (lib.mkIf (cfg.hypervisor == "vmware") {
      virtualisation.vmware.guest.enable = true;
    })
    (lib.mkIf (cfg.hypervisor == "hyperv") {
      virtualisation.hypervGuest.enable = true;
    })
  ];
}
