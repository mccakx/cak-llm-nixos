{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.cak.home.hyprland;
in
{
  options.cak.home.hyprland.enable =
    lib.mkEnableOption "Hyprland user session (bar, launcher, terminal, notifications)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      cliphist
      grim
      slurp
      swappy
      brightnessctl
      playerctl
      pavucontrol
      pcmanfm # lightweight file manager
      swaybg # solid-colour wallpaper (no image asset needed)
      networkmanagerapplet
    ];

    # ---- Compositor -------------------------------------------------------
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$mod" = "SUPER";
        "$terminal" = "foot";
        "$menu" = "fuzzel";

        monitor = ",preferred,auto,1";

        env = [
          "XCURSOR_SIZE,24"
        ];

        # VM-friendly: software cursor avoids the invisible-cursor bug
        # that plagues Hyprland under virtio-gpu.
        cursor.no_hardware_cursors = true;

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          vfr = true; # save CPU when the screen is idle
        };

        exec-once = [
          "swaybg -c 1e1e2e"
          "waybar"
          "mako"
          "nm-applet --indicator"
          "wl-paste --watch cliphist store"
        ];

        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          layout = "dwindle";
        };

        decoration = {
          rounding = 6;
          blur.enabled = false; # cheaper in a VM
        };

        animations.enabled = true;

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad.natural_scroll = true;
        };

        bind = [
          "$mod, Return, exec, $terminal"
          "$mod, D, exec, $menu"
          "$mod, B, exec, firefox"
          "$mod, E, exec, pcmanfm"
          "$mod, Q, killactive,"
          "$mod, F, fullscreen,"
          "$mod, V, togglefloating,"
          "$mod, L, exec, hyprlock"
          "$mod SHIFT, E, exit,"
          # focus movement
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          # screenshot region -> annotate
          ", Print, exec, grim -g \"$(slurp)\" - | swappy -f -"
        ]
        # workspaces 1..9 (switch + move-window)
        ++ builtins.concatLists (
          builtins.genList (
            i:
            let
              n = toString (i + 1);
            in
            [
              "$mod, ${n}, workspace, ${n}"
              "$mod SHIFT, ${n}, movetoworkspace, ${n}"
            ]
          ) 9
        );

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        binde = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ];
      };
    };

    # ---- Terminal / launcher / notifications / lock -----------------------
    programs.foot = {
      enable = true;
      settings.main.font = "JetBrainsMono Nerd Font:size=11";
    };

    programs.fuzzel.enable = true;
    programs.hyprlock.enable = true;
    services.mako.enable = true;

    # ---- Status bar -------------------------------------------------------
    programs.waybar = {
      enable = true;
      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "tray"
        ];
        clock.format = "{:%a %d %b  %H:%M}";
        cpu.format = "  {usage}%";
        memory.format = "  {}%";
        network = {
          format-wifi = "  {essid}";
          format-ethernet = "  {ipaddr}";
          format-disconnected = "睊";
        };
        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "  muted";
          format-icons.default = [ "" "" "" ];
          on-click = "pavucontrol";
        };
        tray.spacing = 8;
      };
      style = ''
        * { font-family: "JetBrainsMono Nerd Font"; font-size: 12px; }
        window#waybar { background: rgba(30,30,46,0.85); color: #cdd6f4; }
        #workspaces button { padding: 0 8px; color: #cdd6f4; }
        #workspaces button.active { background: #585b70; border-radius: 4px; }
        #clock, #cpu, #memory, #network, #pulseaudio, #tray { padding: 0 10px; }
      '';
    };

    # Point GTK apps at a coherent dark theme so nothing looks broken OOTB.
    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
    };
  };
}
