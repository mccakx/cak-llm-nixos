{ ... }:
{
  # Home Manager modules. Same pattern as the NixOS side: `cak.home.*`
  # toggles that hosts/users opt into.
  imports = [
    ./core.nix
    ./browser.nix
    ./hyprland.nix
  ];
}
