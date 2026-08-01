{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./nginx.nix
    ./forgejo.nix
    ./grafana.nix
    ./users/lachlan.nix

    ../../modules/system/boot.nix
    ../../modules/system/core.nix
    ../../modules/system/persistence.nix
    ../../modules/system/secrets.nix
    ../../modules/system/ssh.nix
    ../../modules/system/home-manager.nix

    ../../modules/locales/australia-brisbane.nix
  ];

  networking.hostName = "ritsuko";
  networking.useNetworkd = true;

  local.persistence.enable = true;

  system.stateVersion = "26.05";
}
