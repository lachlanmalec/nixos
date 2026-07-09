{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.persistence;

  entryType = with lib.types; either str attrs;

  normalUsers = lib.filterAttrs (_: u: u.isNormalUser) config.users.users;

  # path that identifies an entry, used for dedupe
  entryKey = e: if lib.isString e then e else e.directory;

  # first declaration of a path wins
  dedupeBy =
    key: list: lib.attrValues (builtins.listToAttrs (map (e: lib.nameValuePair (key e) e) list));

  userDirsFor =
    name:
    dedupeBy entryKey (
      cfg.userDirectories ++ (config.home-manager.users.${name}.local.persistence.directories or [ ])
    );
in
{
  options.local.persistence = {
    systemDirectories = lib.mkOption {
      type = lib.types.listOf entryType;
      default = [ ];
      description = "Directories persisted at the system level.";
    };

    systemFiles = lib.mkOption {
      type = lib.types.listOf entryType;
      default = [ ];
      description = "Files persisted at the system level.";
    };

    userDirectories = lib.mkOption {
      type = lib.types.listOf entryType;
      default = [ ];
      description = "Home-relative directories persisted for every normal user.";
    };

    userSyncedFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Home-relative paths of files that applications rewrite atomically
        (write temp + rename). These cannot be bind-mounted; they are
        restored from /persist at boot and copied back whenever they change.
      '';
    };
  };

  config = {
    boot.initrd.systemd.enable = true;

    fileSystems."/persist".neededForBoot = true;

    boot.initrd.systemd.services.rollback = {
      description = "Rollback btrfs root subvolume to a clean state";
      wantedBy = [ "initrd.target" ];
      after = [ "initrd-root-device.target" ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /mnt
        mount -o subvol=/ /dev/disk/by-partlabel/disk-main-root /mnt
        if [[ -e /mnt/root ]]; then
          mkdir -p /mnt/old_roots
          timestamp=$(date --date="@$(stat -c %Y /mnt/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /mnt/root "/mnt/old_roots/$timestamp"
        fi
        delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/mnt/$i"
          done
          btrfs subvolume delete "$1"
        }
        for i in $(find /mnt/old_roots/ -maxdepth 1 -mtime +30 2>/dev/null); do
          delete_subvolume_recursively "$i"
        done
        btrfs subvolume create /mnt/root
        umount /mnt
      '';
    };

    # per-user persistence option, declared for every home-manager user;
    # collected into preservation below
    home-manager.sharedModules = [
      {
        options.local.persistence.directories = lib.mkOption {
          type = lib.types.listOf entryType;
          default = [ ];
          description = "Home-relative directories persisted for this user.";
        };
      }
    ];

    preservation = {
      enable = true;
      preserveAt."/persist" = {
        files = cfg.systemFiles;
        directories = dedupeBy entryKey cfg.systemDirectories;
        users = lib.mapAttrs (name: _: {
          directories = userDirsFor name;
        }) normalUsers;
      };
    };

    local.persistence = {
      userDirectories = [
        # claude code
        {
          directory = ".config/claude";
          mode = "0700";
        }

        # vesktop (settings and discord session)
        {
          directory = ".config/vesktop";
          mode = "0700";
        }

        # spotify (login and settings; cache stays ephemeral)
        {
          directory = ".config/spotify";
          mode = "0700";
        }

        # zed-editor (settings; extensions, language servers and workspace state)
        ".config/zed"
        ".local/share/zed"

        # google-chrome (profiles, logins, extensions; cache stays ephemeral)
        {
          directory = ".config/google-chrome";
          mode = "0700";
        }

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

        # gnome
        ".config/autostart"
        ".local/share/backgrounds"
        ".local/share/gnome-shell"
        {
          directory = ".config/dconf";
          mode = "0700";
        }
        {
          directory = ".config/goa-1.0";
          mode = "0700";
        }
        {
          directory = ".config/evolution";
          mode = "0700";
        }
        {
          directory = ".local/share/evolution";
          mode = "0700";
        }
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
      ];
    };

    # GNOME rewrites these files atomically (write temp + rename), which breaks
    # per-file bind mounts and symlinks. Instead, restore them from /persist at
    # boot (before the session starts) and copy them back whenever GNOME
    # rewrites them.
    systemd.tmpfiles.settings.preservation-gnome-loose-files = {
      # monitor layout configured in Display Settings
      "/home/lachlan/.config/monitors.xml".C = {
        user = "lachlan";
        group = "users";
        mode = "0644";
        argument = "/persist/home/lachlan/.config/monitors.xml";
      };
      # default application (mime type) choices
      "/home/lachlan/.config/mimeapps.list".C = {
        user = "lachlan";
        group = "users";
        mode = "0644";
        argument = "/persist/home/lachlan/.config/mimeapps.list";
      };
      # sidebar bookmarks in Files and GTK3/GTK4 file dialogs; the rest of
      # gtk-3.0/gtk-4.0 is managed declaratively / defaults
      "/home/lachlan/.config/gtk-3.0".d = {
        user = "lachlan";
        group = "users";
        mode = "0755";
      };
      "/home/lachlan/.config/gtk-3.0/bookmarks".C = {
        user = "lachlan";
        group = "users";
        mode = "0644";
        argument = "/persist/home/lachlan/.config/gtk-3.0/bookmarks";
      };
    };

    home-manager.users."lachlan" = {
      systemd.user.paths.persist-gnome-loose-files = {
        Unit.Description = "Watch GNOME loose config files for changes";
        Path.PathChanged = [
          "%h/.config/monitors.xml"
          "%h/.config/mimeapps.list"
          "%h/.config/gtk-3.0/bookmarks"
        ];
        Install.WantedBy = [ "default.target" ];
      };
      systemd.user.services.persist-gnome-loose-files = {
        Unit.Description = "Copy GNOME loose config files to persistent storage";
        Service = {
          Type = "oneshot";
          ExecStart = toString (
            pkgs.writeShellScript "persist-gnome-loose-files" ''
              for f in monitors.xml mimeapps.list gtk-3.0/bookmarks; do
                if [ -f "$HOME/.config/$f" ]; then
                  mkdir -p "$(dirname "/persist/home/lachlan/.config/$f")"
                  cp -p "$HOME/.config/$f" "/persist/home/lachlan/.config/$f"
                fi
              done
            ''
          );
        };
      };
    };

    systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
  };
}
