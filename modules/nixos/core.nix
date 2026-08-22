{ pkgs, lib, ... }:
{
  # ---- Nix daemon & flakes -----------------------------------------------
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
      # Be tolerant of transient substituter outages.
      connect-timeout = 5;
      fallback = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # ---- Locale / time / console ------------------------------------------
  time.timeZone = "Asia/Jakarta";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_NUMERIC = "id_ID.UTF-8";
      LC_TIME = "id_ID.UTF-8";
      LC_MONETARY = "id_ID.UTF-8";
      LC_PAPER = "id_ID.UTF-8";
      LC_MEASUREMENT = "id_ID.UTF-8";
    };
  };

  console.keyMap = "us";

  # ---- Lightweight footprint --------------------------------------------
  # Trim docs the VM does not need; keep it snappy on modest resources.
  documentation.nixos.enable = false;
  documentation.doc.enable = false;

  # Compressed RAM swap: helps a memory-constrained VM stay responsive.
  zramSwap.enable = true;

  # ---- Base CLI toolkit (available on every machine) --------------------
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    vim
    nano
    htop
    btop
    fastfetch
    tree
    ripgrep
    fd
    bat
    eza
    unzip
    zip
    p7zip
    pciutils
    usbutils
  ];

  environment.variables.EDITOR = "nano";
}
