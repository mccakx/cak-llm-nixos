{
  description = "cak-llm-nixos — modular, scalable NixOS + Home Manager flake";

  inputs = {
    # Pin to the current stable channel (matches the latest NixOS ISO).
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # A rolling channel, exposed to every host as `pkgs.unstable.<name>`
    # via the overlay — cherry-pick newer packages without leaving stable.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      # Systems we produce dev shells / formatters for.
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = lib.genAttrs systems;

      # A nixpkgs instance with our overlay + unfree, per system.
      pkgsFor = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ self.overlays.default ];
        };

      # Our own tiny library: the host factory lives here.
      mylib = import ./lib { inherit inputs; };
    in
    {
      # ---- Reusable outputs (importable from other flakes) --------------
      lib = mylib;
      overlays.default = import ./overlays { inherit inputs; };
      nixosModules.default = import ./modules/nixos;
      homeManagerModules.default = import ./modules/home;

      # ---- Machines -----------------------------------------------------
      # Each host is one line here. Everything about *what* a machine is
      # lives in ./hosts/<name>/ as feature toggles.
      nixosConfigurations = {
        llm-vm = mylib.mkHost {
          hostname = "llm-vm";
          system = "x86_64-linux";
          username = "cak";
        };

        # To add a machine, copy ./hosts/llm-vm -> ./hosts/<name>,
        # adjust its toggles + hardware-configuration.nix, then add:
        #
        # <name> = mylib.mkHost {
        #   hostname = "<name>";
        #   system = "x86_64-linux";
        #   username = "cak";
        # };
      };

      # ---- Dev experience ----------------------------------------------
      formatter = forAllSystems (system: (pkgsFor system).nixfmt-rfc-style);

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            name = "cak-llm-nixos";
            packages = with pkgs; [
              nixfmt-rfc-style # formatter
              nil # nix language server
              nixd # alt nix language server
              nix-output-monitor # prettier `nom build`
              nvd # diff generations
              git
            ];
            shellHook = ''
              echo "cak-llm-nixos dev shell — try:  nix run .#vm   |   nix fmt   |   nix flake check"
            '';
          };
        }
      );

      # `nix run .#vm` boots a throwaway graphical QEMU VM of llm-vm.
      # Great for testing the whole config before touching a real disk.
      apps.x86_64-linux.vm = {
        type = "app";
        program = "${self.nixosConfigurations.llm-vm.config.system.build.vm}/bin/run-llm-vm-vm";
      };

      # `nix flake check` builds the machine(s) + verifies formatting.
      checks.x86_64-linux = {
        llm-vm = self.nixosConfigurations.llm-vm.config.system.build.toplevel;
      };
    };
}
