{ ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # This is the whole machine definition: pick features, done.
  cak = {
    desktop.environment = "xfce";
    audio.enable = true;
    guest.hypervisor = "qemu";
    remote.rdp.enable = true; # RDP via Remmina on 3389

    # Off for this lightweight VM; flip on when you need them.
    virtualisation.podman.enable = false;
    virtualisation.libvirt.enable = false;
    gaming.enable = false;
  };

  # The NixOS release this machine was first installed with.
  # Do not change on an existing install.
  system.stateVersion = "26.05";
}
