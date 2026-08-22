{ lib, ... }:
{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5; # cap boot menu / keep disk usage sane
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };

    # Default kernel is the lightweight, well-tested choice for a VM.
    # Swap to `pkgs.linuxPackages_latest` here if you need newer hardware
    # support on future bare-metal hosts.
    # kernelPackages = pkgs.linuxPackages_latest;

    # tmpfs /tmp: faster, self-cleaning, less disk churn.
    tmp.useTmpfs = lib.mkDefault true;
  };
}
