{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./locale.nix
    ./users/lachlan.nix

    ../../modules/boot.nix
    ../../modules/nix.nix
    ../../modules/core.nix
    ../../modules/persistence.nix

    ../../modules/home-manager.nix
  ];

  networking.hostName = "ritsuko";
  networking.useNetworkd = true;

  local.persistence.enable = true;
  # headless host administered only over SSH: keep host keys stable across
  # root-subvolume rollbacks so clients don't see host-key-changed warnings
  local.persistence.systemDirectories = [
    "/etc/ssh"
  ];

  system.stateVersion = "26.05";
}
