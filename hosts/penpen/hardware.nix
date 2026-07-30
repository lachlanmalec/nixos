{ modulesPath, lib, ... }:

{
  imports = [
    # the installer ISO's rescue toolset: parted, gptfdisk, ddrescue,
    # cryptsetup, smartmontools, ...
    (modulesPath + "/profiles/base.nix")
  ];

  # the installer ISO's hardware coverage: ~90 initrd storage-controller
  # modules + redistributable firmware (wifi on random laptops); this is
  # the current spelling of the deprecated profiles/all-hardware.nix import
  hardware.enableAllHardware = true;

  # no ZFS pools to rescue; keeps the ZFS kernel module out of the closure
  boot.supportedFilesystems.zfs = lib.mkForce false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
