{
  pkgs,
  lib,
  config,
  username,
  ...
}:
{
  # Zsh is the login shell; the interactive config lives in Home Manager.
  programs.zsh.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    # Temporary password so you can log in on first boot.
    # CHANGE IT after install:  passwd
    initialPassword = "nixos";
    shell = pkgs.zsh;
    extraGroups =
      [
        "wheel" # sudo
        "networkmanager"
        "video"
        "audio"
      ]
      # Groups added only when the matching feature is enabled.
      ++ lib.optional config.cak.virtualisation.podman.enable "podman"
      ++ lib.optional config.cak.virtualisation.libvirt.enable "libvirtd";
  };

  security.sudo.wheelNeedsPassword = true;
}
