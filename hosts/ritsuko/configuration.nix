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
    ../../modules/ssh.nix

    ../../modules/home-manager.nix
  ];

  networking.hostName = "ritsuko";
  networking.useNetworkd = true;

  local.persistence.enable = true;

  system.stateVersion = "26.05";
}
