{ ... }:
{
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ]; # ssh
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      # Password auth is on so the VM is reachable out of the box.
      # Switch to key-only once you've added an authorized key.
      PasswordAuthentication = true;
    };
  };
}
