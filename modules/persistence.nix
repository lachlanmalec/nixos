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

  # all cumulative path prefixes: ".config/gtk-3.0" -> [ ".config" ".config/gtk-3.0" ]
  prefixesOf =
    path:
    let
      parts = lib.splitString "/" path;
    in
    lib.foldl' (acc: part: acc ++ [ (if acc == [ ] then part else "${lib.last acc}/${part}") ]) [ ] parts;

  # strict ancestor directories of a file path
  ancestorsOf = path: lib.filter (p: p != ".") (prefixesOf (dirOf path));

  # directories that preservation already creates for a user (persisted dirs
  # and their intermediate parents); synced files must not duplicate these
  coveredFor = name: lib.unique (lib.concatMap prefixesOf (map entryKey (userDirsFor name)));

  # parent directories the synced-file rules must create themselves
  syncedParentsFor =
    name:
    lib.filter (a: !(lib.elem a (coveredFor name))) (
      lib.unique (lib.concatMap ancestorsOf cfg.userSyncedFiles)
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
      {
        config = lib.mkIf (cfg.userSyncedFiles != [ ]) {
          systemd.user.paths.local-persistence-synced-files = {
            Unit.Description = "Watch synced persistence files for changes";
            Path.PathChanged = map (f: "%h/${f}") cfg.userSyncedFiles;
            Install.WantedBy = [ "default.target" ];
          };
          systemd.user.services.local-persistence-synced-files = {
            Unit.Description = "Copy synced persistence files to persistent storage";
            Service = {
              Type = "oneshot";
              ExecStart = toString (
                pkgs.writeShellScript "local-persistence-synced-files" ''
                  for f in ${lib.escapeShellArgs cfg.userSyncedFiles}; do
                    if [ -f "$HOME/$f" ]; then
                      mkdir -p "$(dirname "/persist$HOME/$f")"
                      cp -p "$HOME/$f" "/persist$HOME/$f"
                    fi
                  done
                ''
              );
            };
          };
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

        # google-chrome (profiles, logins, extensions; cache stays ephemeral)
        {
          directory = ".config/google-chrome";
          mode = "0700";
        }
      ];
    };

    # Files listed in local.persistence.userSyncedFiles are rewritten
    # atomically by their applications (write temp + rename), which breaks
    # per-file bind mounts and symlinks. Instead, restore them from /persist
    # at boot (before any session starts) and copy them back whenever they
    # change.
    systemd.tmpfiles.settings.local-persistence-synced-files =
      lib.mkIf (cfg.userSyncedFiles != [ ]) (
        lib.mkMerge (
          lib.mapAttrsToList (
            name: user:
            builtins.listToAttrs (
              (map (
                p:
                lib.nameValuePair "${user.home}/${p}" {
                  d = {
                    user = name;
                    group = user.group;
                    mode = "0755";
                  };
                }
              ) (syncedParentsFor name))
              ++ (map (
                f:
                lib.nameValuePair "${user.home}/${f}" {
                  C = {
                    user = name;
                    group = user.group;
                    mode = "0644";
                    argument = "/persist${user.home}/${f}";
                  };
                }
              ) cfg.userSyncedFiles)
            )
          ) normalUsers
        )
      );

    systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
  };
}
