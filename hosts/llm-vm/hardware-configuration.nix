{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
# TEMPLATE for a QEMU/KVM (virt-manager) VM with a single virtio disk
# partitioned + labelled exactly as in the README:
#   - ESP   (FAT32)  labelled  ESP   -> /boot
#   - root  (btrfs)  labelled  nixos -> subvolumes @ (/), @home (/home), @nix (/nix)
#
# On the real machine you can instead run `nixos-generate-config` and drop
# its hardware-configuration.nix in here — this file is just a working
# default so `nix flake check` builds and a clean install boots OOTB.
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "xhci_pci"
    "sr_mod"
    "ahci"
  ];
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd:1" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd:1" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd:1" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
