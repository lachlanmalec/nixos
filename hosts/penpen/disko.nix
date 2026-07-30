{ ... }:

{
  disko.devices = {
    disk = {
      # NOT named "main": that partlabel convention belongs to the
      # btrfs-rollback hosts; penpen has nothing to roll back
      usb = {
        type = "disk";
        # ignored during image builds (a virtual disk is substituted);
        # only used if disko is ever run against a real stick
        device = "/dev/disk/by-id/usb-penpen";
        # qemu-img binary units: 28GiB ≈ 30.1 GB decimal — fits a "32 GB"
        # stick; 30G would not
        imageSize = "28G";
        imageName = "penpen";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            nix = {
              priority = 2;
              name = "nix";
              size = "24G";
              content = {
                type = "filesystem";
                format = "ext4";
                # all of /nix (store, db, profiles) lives here, so
                # nixos-rebuild works on-stick and generations persist
                mountpoint = "/nix";
              };
            };
            persist = {
              name = "persist";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/persist";
              };
            };
          };
        };
      };
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "mode=0755"
        "size=8G"
      ];
    };
  };
}
