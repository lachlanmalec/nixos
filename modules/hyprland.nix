{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # kitty is Hyprland's default terminal (referenced by the default keybinds)
    kitty

    # theming packages installed system-wide (as GNOME would) so GTK/Qt
    # applications detect the Adwaita themes regardless of the launching user
    gnome-themes-extra # Adwaita / Adwaita-dark GTK theme
    adwaita-icon-theme # Adwaita icon + cursor theme
    adwaita-qt # Adwaita style for Qt 5
    adwaita-qt6 # Adwaita style for Qt 6
    qadwaitadecorations # Adwaita window decorations for Qt (platform theme)
    qadwaitadecorations-qt6
  ];

  # Adwaita fonts, installed system-wide so they are discoverable by fontconfig
  fonts.packages = [ pkgs.adwaita-fonts ];

  # Hyprland (Wayland only), launched via UWSM as recommended by the NixOS
  # wiki: https://wiki.nixos.org/wiki/Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # ly as the display manager
  services.displayManager.ly.enable = true;

  # polkit daemon, required by the Hyprland polkit agent below
  security.polkit.enable = true;

  # secret service (Secret Service API) for apps like Chrome, libsecret
  # consumers, etc. ly auto-wires the PAM module, so the keyring unlocks with
  # the login password.
  services.gnome.gnome-keyring.enable = true;

  # backends for ashell's power indicators (org.freedesktop.UPower and its
  # PowerProfiles). On this desktop the battery indicator stays empty, but
  # these are harmless and drive the power-profile switcher.
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # enable the Hyprland home-manager module for all home-manager users;
  # disable its systemd integration since UWSM manages the session
  home-manager.sharedModules = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = false;

          # generate a Lua config (~/.config/hypr/hyprland.lua) instead of the
          # legacy hyprlang hyprland.conf
          configType = "lua";

          settings =
            let
              # raw Lua expression helper (rendered verbatim in hyprland.lua)
              inline = lib.generators.mkLuaInline;

              # mod + N focuses workspace N; mod + shift + N moves the active
              # window to workspace N. Workspace 10 is bound to the "0" key.
              workspaceBinds = lib.concatMap (
                n:
                let
                  key = if n == 10 then "0" else toString n;
                in
                [
                  {
                    _args = [
                      (inline ''mod .. " + ${key}"'')
                      (inline ''hl.dsp.focus({ workspace = "${toString n}" })'')
                    ];
                  }
                  {
                    _args = [
                      (inline ''mod .. " + SHIFT + ${key}"'')
                      (inline ''hl.dsp.window.move({ workspace = "${toString n}" })'')
                    ];
                  }
                ]
              ) (lib.range 1 10);
            in
            {
              # variables, rendered as Lua locals (local mod = "ALT", etc.)
              mod = {
                _var = "ALT";
              };
              terminal = {
                _var = "kitty";
              };

              # default catch-all monitor (empty output matches every monitor):
              # highest resolution and refresh rate, automatic position and scale
              monitor = {
                output = "";
                mode = "highres";
                position = "auto";
                scale = "auto";
              };

              # styling: gaps + appearance
              config = {
                general = {
                  gaps_in = 5;
                  gaps_out = 20;
                  border_size = 2;
                  layout = "dwindle";
                };
                decoration = {
                  rounding = 10;
                  active_opacity = 1.0;
                  inactive_opacity = 1.0;
                  blur = {
                    enabled = true;
                    size = 3;
                    passes = 1;
                  };
                };
                # disable all animations
                animations = {
                  enabled = false;
                };
              };

              # keybindings
              bind = [
                # launch the terminal: mod + Enter
                {
                  _args = [
                    (inline ''mod .. " + RETURN"'')
                    (inline "hl.dsp.exec_cmd(terminal)")
                  ];
                }

                # toggle the application launcher: mod + D
                {
                  _args = [
                    (inline ''mod .. " + D"'')
                    (inline ''hl.dsp.exec_cmd("hyprlauncher --toggle")'')
                  ];
                }

                # move focus between windows: mod + arrow keys
                {
                  _args = [
                    (inline ''mod .. " + left"'')
                    (inline ''hl.dsp.focus({ direction = "left" })'')
                  ];
                }
                {
                  _args = [
                    (inline ''mod .. " + right"'')
                    (inline ''hl.dsp.focus({ direction = "right" })'')
                  ];
                }
                {
                  _args = [
                    (inline ''mod .. " + up"'')
                    (inline ''hl.dsp.focus({ direction = "up" })'')
                  ];
                }
                {
                  _args = [
                    (inline ''mod .. " + down"'')
                    (inline ''hl.dsp.focus({ direction = "down" })'')
                  ];
                }

                # move the active window: mod + shift + arrow keys
                {
                  _args = [
                    (inline ''mod .. " + SHIFT + left"'')
                    (inline ''hl.dsp.window.move({ direction = "left" })'')
                  ];
                }
                {
                  _args = [
                    (inline ''mod .. " + SHIFT + right"'')
                    (inline ''hl.dsp.window.move({ direction = "right" })'')
                  ];
                }
                {
                  _args = [
                    (inline ''mod .. " + SHIFT + up"'')
                    (inline ''hl.dsp.window.move({ direction = "up" })'')
                  ];
                }
                {
                  _args = [
                    (inline ''mod .. " + SHIFT + down"'')
                    (inline ''hl.dsp.window.move({ direction = "down" })'')
                  ];
                }

                # close the active window: mod + Q
                {
                  _args = [
                    (inline ''mod .. " + Q"'')
                    (inline "hl.dsp.window.close()")
                  ];
                }

                # quit Hyprland: mod + shift + Q
                {
                  _args = [
                    (inline ''mod .. " + SHIFT + Q"'')
                    (inline "hl.dsp.exit()")
                  ];
                }

                # mouse: hold mod + left-drag to move a window
                {
                  _args = [
                    (inline ''mod .. " + mouse:272"'')
                    (inline "hl.dsp.window.drag()")
                    { mouse = true; }
                  ];
                }
                # mouse: hold mod + right-drag to resize a window (from the
                # grabbed edge/corner)
                {
                  _args = [
                    (inline ''mod .. " + mouse:273"'')
                    (inline "hl.dsp.window.resize()")
                    { mouse = true; }
                  ];
                }
              ]
              ++ workspaceBinds;
            };
        };

        # Hyprland polkit agent (started with the graphical session, which
        # UWSM brings up)
        services.hyprpolkitagent.enable = true;

        # application launcher, run as a daemon in the graphical session and
        # toggled via the mod + D keybind above
        services.hyprlauncher.enable = true;

        # status bar + notification daemon. ashell serves
        # org.freedesktop.Notifications, but only when the Notifications module
        # is in the layout, so it is included in the right group below.
        programs.ashell = {
          enable = true;
          systemd.enable = true;
          settings = {
            # non-floating, full-width bar instead of the default floating
            # "Islands" style
            appearance.style = "Solid";
            modules = {
              left = [ "Workspaces" ];
              center = [ "WindowTitle" ];
              right = [
                "SystemInfo"
                [
                  "Notifications"
                  "Tray"
                  "Tempo"
                  "Privacy"
                  "Settings"
                ]
              ];
            };
          };
        };

        # ashell (iced/wgpu) renders black on this Nvidia GPU: the wgpu
        # EGL/Vulkan path cannot obtain a valid framebuffer config. Force
        # iced's software renderer, which is plenty for a status bar. (Merges
        # into the unit generated by programs.ashell above.)
        systemd.user.services.ashell.Service.Environment = [ "ICED_BACKEND=tiny-skia" ];

        # wallpaper daemon; use wallpaper.png from the repo root on every
        # monitor (empty monitor = all). The path is copied into the store.
        services.hyprpaper = {
          enable = true;
          settings = {
            ipc = "on";
            splash = false;
            preload = [ "${../wallpaper.png}" ];
            wallpaper = [
              {
                monitor = "";
                path = "${../wallpaper.png}";
              }
            ];
          };
        };

        # GTK theming (per the Hyprland home-manager docs), Adwaita-dark
        gtk = {
          enable = true;
          theme = {
            name = "Adwaita-dark";
            package = pkgs.gnome-themes-extra;
          };
          iconTheme = {
            name = "Adwaita";
            package = pkgs.adwaita-icon-theme;
          };
          font = {
            name = "Adwaita Sans";
            package = pkgs.adwaita-fonts;
            size = 11;
          };
          colorScheme = "dark";
        };

        # cursor theme applied across GTK and the Wayland session (sets
        # XCURSOR_THEME / XCURSOR_SIZE, propagated to UWSM via uwsm/env)
        home.pointerCursor = {
          gtk.enable = true;
          package = pkgs.adwaita-icon-theme;
          name = "Adwaita";
          size = 24;
        };

        # Qt theming to match: Adwaita platform theme, Adwaita-dark style
        qt = {
          enable = true;
          platformTheme.name = "adwaita";
          style.name = "adwaita-dark";
        };

        # expose home-manager's session variables to the system-level UWSM
        # session (per the Hyprland home-manager docs)
        xdg.configFile."uwsm/env".source =
          "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
      }
    )
  ];

  local.persistence.userDirectories = [
    # xdg user directories
    "Desktop"
    "Documents"
    "Downloads"
    "Music"
    "Pictures"
    "Projects"
    "Public"
    "Templates"
    "Videos"

    # hyprland
    ".config/hypr"
    ".local/share/hyprland"
    ".local/share/hyprlauncher" # launcher usage-frequency cache

    # gnome-keyring secret store (Secret Service). Without this the login
    # keyring and every stored secret (e.g. Chrome's Safe Storage key) are
    # wiped on each boot.
    {
      directory = ".local/share/keyrings";
      mode = "0700";
    }
  ];
}
