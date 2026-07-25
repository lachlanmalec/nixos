{ ... }:

{
  imports = [
    ./wsl.nix
    ./locale.nix
    ./users/lachlan.nix

    ../../modules/nix.nix
    ../../modules/core.nix
    ../../modules/gpg.nix
    # imported for its local.persistence.* option declarations only; the
    # impermanence implementation stays disabled — WSL mounts the rootfs
    # itself, so there is no initrd in which to roll back a subvolume
    ../../modules/persistence.nix

    ../../modules/home-manager.nix
  ];

  networking.hostName = "kaworu";

  system.stateVersion = "26.05";
}
