{ inputs }:
let
  inherit (inputs) nixpkgs home-manager;
in
{
  # mkHost: the single factory that builds every machine.
  #
  #   hostname   -> becomes networking.hostName AND selects ./hosts/<hostname>
  #   system     -> platform double, defaults to x86_64-linux
  #   username   -> the primary user; selects ./home/<username>.nix
  #   extraModules -> escape hatch for one-off NixOS modules
  mkHost =
    {
      hostname,
      system ? "x86_64-linux",
      username ? "cak",
      extraModules ? [ ],
    }:
    nixpkgs.lib.nixosSystem {
      inherit system;

      # Everything downstream can read inputs/hostname/username directly.
      specialArgs = { inherit inputs hostname username; };

      modules = [
        # Shared, option-driven module set (defines the `cak.*` namespace).
        ../modules/nixos

        # Per-machine config (hardware + which features to switch on).
        ../hosts/${hostname}

        # Home Manager as a NixOS module.
        home-manager.nixosModules.home-manager

        # Glue that is identical for every host.
        (
          { ... }:
          {
            networking.hostName = hostname;

            nixpkgs.hostPlatform = system;
            nixpkgs.overlays = [ (import ../overlays { inherit inputs; }) ];
            nixpkgs.config.allowUnfree = true;

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = { inherit inputs hostname username; };
              users.${username} = import ../home/${username}.nix;
            };
          }
        )
      ]
      ++ extraModules;
    };
}
