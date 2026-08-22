{ pkgs, lib, ... }:
{
  # Always-on user tooling (shell, prompt, multiplexer, dev niceties).
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      autocd = true;
      history = {
        size = 50000;
        save = 50000;
        ignoreDups = true;
        ignoreSpace = true;
        share = true;
      };
      shellAliases = {
        ls = "eza --group-directories-first";
        ll = "eza -l --group-directories-first --git";
        la = "eza -la --group-directories-first --git";
        cat = "bat";
        rebuild = "sudo nixos-rebuild switch --flake ~/cak-llm-nixos";
      };
    };

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        # user@host (only over SSH) → path → git → duration, then a fresh
        # line with a colored prompt arrow.
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_status"
          "$cmd_duration"
          "$line_break"
          "$character"
        ];
        username = {
          style_user = "bold blue";
          style_root = "bold red";
          format = "[$user]($style)";
          show_always = false;
        };
        hostname = {
          ssh_only = true;
          format = "[@$hostname](bold green) ";
        };
        directory = {
          truncation_length = 3;
          truncate_to_repo = true;
          style = "bold cyan";
        };
        git_branch = {
          symbol = " ";
          style = "bold purple";
        };
        git_status.style = "bold yellow";
        cmd_duration = {
          min_time = 500;
          format = "took [$duration](bold yellow) ";
        };
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vimcmd_symbol = "[❮](bold green)";
        };
      };
    };

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

    # AI coding CLIs — tracked on unstable so they stay current.
    unstable.claude-code
    unstable.opencode
  ];
}
