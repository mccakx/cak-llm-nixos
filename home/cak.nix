{ username, ... }:
{
  # Per-user Home Manager config. Imports the shared HM module set and
  # switches on the features this user wants.
  imports = [ ../modules/home ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
  };

  cak.home = {
    # Hyprland user session — enable only when the host uses Hyprland.
    hyprland.enable = false;
    browser.firefox.enable = true;
  };

  programs.home-manager.enable = true;
}
