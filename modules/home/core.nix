{ pkgs, ... }:
{
  # Always-on user tooling (shell, prompt, multiplexer, dev niceties).
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        ls = "eza --group-directories-first";
        ll = "eza -l --group-directories-first --git";
        la = "eza -la --group-directories-first --git";
        cat = "bat";
        rebuild = "sudo nixos-rebuild switch --flake ~/cak-llm-nixos";
      };
    };

    starship.enable = true;

    git = {
      enable = true;
      settings.init.defaultBranch = "main";
    };

    tmux = {
      enable = true;
      clock24 = true;
      extraConfig = "set -g mouse on";
    };

    btop.enable = true;

    # Auto-load per-project dev environments.
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  home.packages = with pkgs; [
    fastfetch
    ripgrep
    fd
    bat
    eza
    tree
  ];
}
