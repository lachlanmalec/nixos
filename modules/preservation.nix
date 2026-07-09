{ ... }:

{
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

  preservation = {
    enable = true;
    preserveAt."/persist" = {
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
      ];
      directories = [
        "/var/lib/systemd/timers"
        "/var/lib/nixos"
        "/var/log"
        "/var/lib/sbctl"

        # imperative connectivity
        "/var/lib/bluetooth"
        "/etc/NetworkManager/system-connections"

        # flatpak
        "/var/lib/flatpak"
      ];
      users.lachlan = {
        directories = [
          # flatpack
          ".local/share/flatpak"
          ".var/app" # flatpak per-app user data

          # 1password
          {
            directory = ".config/1Password";
            mode = "0700";
          }
          {
            directory = ".config/op";
            mode = "0700";
          }
        ];
      };
    };
  };

  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
}
