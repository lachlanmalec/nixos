{ ... }:

{
  imports = [
    ./wsl.nix
    ./users/lachlan.nix

    ../../modules/system/core.nix
    ../../modules/system/gpg.nix
    # imported for its local.persistence.* option declarations only; the
    # impermanence implementation stays disabled — WSL mounts the rootfs
    # itself, so there is no initrd in which to roll back a subvolume
    ../../modules/system/persistence.nix
    ../../modules/system/secrets.nix
    ../../modules/system/ssh.nix
    ../../modules/system/home-manager.nix

    ../../modules/locales/australia-brisbane.nix
  ];

  networking.hostName = "kaworu";

  system.stateVersion = "26.05";
}
