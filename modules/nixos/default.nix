{ ... }:
{
  # The shared base. Every file here either applies unconditionally
  # (foundations) or defines `cak.*` options guarded by mkIf so hosts
  # opt in to features. Import order does not matter.
  imports = [
    ./core.nix
    ./boot.nix
    ./networking.nix
    ./fonts.nix
    ./users.nix
    ./audio.nix
    ./desktop.nix
    ./remote.nix
    ./guest.nix
    ./virtualisation.nix
    ./gaming.nix
  ];
}
