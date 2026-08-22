{ inputs }:

# A single overlay that exposes the unstable channel at `pkgs.unstable.*`.
# Use it anywhere:  environment.systemPackages = [ pkgs.unstable.somepkg ];
# Add your own package overrides / fixups below the `unstable` line.
final: prev: {
  unstable = import inputs.nixpkgs-unstable {
    inherit (final) system;
    config.allowUnfree = true;
  };

  # Example override slot (kept empty on purpose):
  # myTool = prev.myTool.overrideAttrs (old: { ... });
}
