{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.cak.home.hyprland;

  # Catppuccin Mocha palette (kept in one place so the whole desktop matches).
  c = {
    base = "1e1e2e";
    surface = "313244";
    overlay = "585b70";
    text = "cdd6f4";
    blue = "89b4fa";
  };
in
{
  options.cak.home.hyprland.enable =
    lib.mkEnableOption "Hyprland user session (bar, launcher, terminal, lock, notifications)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      cliphist
      grim
      slurp
      swappy
      swaybg
      mako
      hypridle
      brightnessctl
      playerctl
      pavucontrol
      pcmanfm # lightweight file manager
      networkmanagerapplet
    ];

    # A real cursor theme (the default X cursor is tiny/ugly on Wayland).
    home.pointerCursor = {
      gtk.enable = true;
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
    };

    # Make Firefox the default for links.
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
      };
    };

    # ---- Compositor -------------------------------------------------------
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$mod" = "SUPER";
        "$terminal" = "foot";
        "$menu" = "fuzzel";
        "$fileManager" = "pcmanfm";

        monitor = ",preferred,auto,1";

        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];

        # VM-friendly: software cursor avoids the invisible-cursor bug under
        # virtio-gpu; vfr saves CPU when idle.
        cursor.no_hardware_cursors = true;

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          vfr = true;
          focus_on_activate = true;
        };

        # Started as children of Hyprland so they inherit the session env
        # (robust without uwsm/systemd juggling).
        exec-once = [
          "swaybg -c ${c.base}"
          "waybar"
          "mako"
          "hypridle"
          "nm-applet --indicator"
          "wl-paste --watch cliphist store"
        ];

        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          "col.active_border" = "rgba(${c.blue}ff)";
          "col.inactive_border" = "rgba(${c.surface}ff)";
          layout = "dwindle";
          resize_on_border = true; # grab any window edge with the mouse
        };

        decoration = {
          rounding = 8;
          blur.enabled = false; # cheaper in a VM
          shadow.enabled = false;
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        animations = {
          enabled = true;
          bezier = [ "easeOut, 0.16, 1, 0.3, 1" ];
          animation = [
            "windows, 1, 4, easeOut"
            "workspaces, 1, 4, easeOut, slide"
            "fade, 1, 4, default"
          ];
        };

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad.natural_scroll = true;
        };

        # Nice defaults for common floating dialogs + the cheatsheet window.
        windowrulev2 = [
          "float, class:^(pavucontrol)$"
          "float, class:^(nm-connection-editor)$"
          "float, class:^(org.pulseaudio.pavucontrol)$"
          "float, title:^(Open File)$"
          "float, title:^(Save File)$"
          "float, class:^(cheatsheet)$"
          "size 820 560, class:^(cheatsheet)$"
          "center, class:^(cheatsheet)$"
        ];

        bind =
          [
            # Core
            "$mod, Return, exec, $terminal"
            "$mod, D, exec, $menu"
            "$mod, B, exec, firefox"
            "$mod, E, exec, $fileManager"
            "$mod, Q, killactive,"
            "$mod, F, fullscreen,"
            "$mod, V, togglefloating,"
            "$mod, P, pseudo,"
            "$mod, J, togglesplit,"
            "$mod, L, exec, loginctl lock-session"
            "$mod SHIFT, Escape, exit,"

            # Clipboard history + emoji-free copy manager
            "$mod, C, exec, cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"

            # Screenshots
            ", Print, exec, grim -g \"$(slurp)\" - | swappy -f -"
            "SHIFT, Print, exec, grim - | wl-copy"

            # Keybind cheatsheet (SUPER + /)
            "$mod, slash, exec, foot -a cheatsheet sh -c 'less ~/.config/hypr/keybinds.txt'"

            # Focus
            "$mod, left, movefocus, l"
            "$mod, right, movefocus, r"
            "$mod, up, movefocus, u"
            "$mod, down, movefocus, d"

            # Move window
            "$mod SHIFT, left, movewindow, l"
            "$mod SHIFT, right, movewindow, r"
            "$mod SHIFT, up, movewindow, u"
            "$mod SHIFT, down, movewindow, d"

            # Resize active window
            "$mod CTRL, left, resizeactive, -40 0"
            "$mod CTRL, right, resizeactive, 40 0"
            "$mod CTRL, up, resizeactive, 0 -40"
            "$mod CTRL, down, resizeactive, 0 40"

            # Scratchpad
            "$mod, S, togglespecialworkspace, magic"
            "$mod SHIFT, S, movetoworkspace, special:magic"

            # Cycle workspaces with the mouse wheel
            "$mod, mouse_down, workspace, e+1"
            "$mod, mouse_up, workspace, e-1"
          ]
          # Workspaces 1..9 (switch + move-window-to)
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

        # Repeat-on-hold: volume, brightness, media.
        bindel = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86MonBrightnessUp, exec, brightnessctl s 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
        ];

        bindl = [
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
        ];
      };
    };

    # ---- Lock screen ------------------------------------------------------
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
          grace = 2;
        };
        background = [ { color = "rgba(${c.base}ff)"; } ];
        input-field = [
          {
            size = "260, 50";
            outline_thickness = 2;
            outer_color = "rgba(${c.blue}ff)";
            inner_color = "rgba(${c.surface}ff)";
            font_color = "rgba(${c.text}ff)";
            placeholder_text = "Password…";
            position = "0, -20";
            halign = "center";
            valign = "center";
          }
        ];
        label = [
          {
            text = "$TIME";
            font_size = 64;
            color = "rgba(${c.text}ff)";
            position = "0, 120";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };

    # ---- Idle: lock at 5 min, screen off at 6 min -------------------------
    xdg.configFile."hypr/hypridle.conf".text = ''
      general {
          lock_cmd = pidof hyprlock || hyprlock
          before_sleep_cmd = loginctl lock-session
          after_sleep_cmd = hyprctl dispatch dpms on
      }
      listener {
          timeout = 300
          on-timeout = loginctl lock-session
      }
      listener {
          timeout = 360
          on-timeout = hyprctl dispatch dpms off
          on-resume = hyprctl dispatch dpms on
      }
    '';

    # ---- Terminal / launcher / notifications ------------------------------
    programs.foot = {
      enable = true;
      settings = {
        main.font = "JetBrainsMono Nerd Font:size=11";
        colors = {
          background = c.base;
          foreground = c.text;
        };
      };
    };

    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=11";
          terminal = "foot";
          width = 40;
          layer = "overlay";
        };
        border = {
          width = 2;
          radius = 8;
        };
        colors = {
          background = "${c.base}f2";
          text = "${c.text}ff";
          selection = "${c.overlay}ff";
          selection-text = "${c.text}ff";
          border = "${c.blue}ff";
          match = "${c.blue}ff";
        };
      };
    };

    xdg.configFile."mako/config".text = ''
      font=JetBrainsMono Nerd Font 10
      background-color=#${c.base}
      text-color=#${c.text}
      border-color=#${c.blue}
      border-size=2
      border-radius=8
      padding=10
      margin=10
      default-timeout=5000
    '';

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
          format-disconnected = "󰖪  offline";
        };
        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "  muted";
          format-icons.default = [ "" "" "" ];
          on-click = "pavucontrol";
        };
        tray.spacing = 8;
      };
      style = ''
        * { font-family: "JetBrainsMono Nerd Font"; font-size: 12px; min-height: 0; }
        window#waybar { background: rgba(30,30,46,0.85); color: #${c.text}; }
        #workspaces button { padding: 0 8px; color: #${c.text}; background: transparent; }
        #workspaces button.active { background: #${c.overlay}; border-radius: 4px; }
        #clock, #cpu, #memory, #network, #pulseaudio, #tray { padding: 0 10px; }
      '';
    };

    # ---- Discoverable keybind cheatsheet (SUPER + /) ----------------------
    xdg.configFile."hypr/keybinds.txt".text = ''
      Hyprland keybinds  (mod = SUPER)

        mod + Return          terminal (foot)
        mod + D               app launcher (fuzzel)
        mod + B               Firefox
        mod + E               file manager
        mod + C               clipboard history
        mod + Q               close window
        mod + F               fullscreen
        mod + V               toggle floating
        mod + L               lock screen
        mod + /               this cheatsheet

        mod + 1..9            switch to workspace
        mod + Shift + 1..9    move window to workspace
        mod + S              /Shift+S   scratchpad show / send
        mod + scroll         cycle workspaces

        mod + arrows              move focus
        mod + Shift + arrows      move window
        mod + Ctrl  + arrows      resize window
        mod + drag (L/R mouse)    move / resize with mouse

        Print                 screenshot region -> annotate (swappy)
        Shift + Print         screenshot region -> clipboard

        mod + Shift + Escape  exit Hyprland

      Press q to close.
    '';
  };
}
