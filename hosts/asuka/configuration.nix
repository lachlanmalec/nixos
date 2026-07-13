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
    ../../modules/firefox.nix
    ../../modules/gpg.nix
    ../../modules/persistence.nix
    ../../modules/network.nix

    ../../modules/hardware/audio.nix
    ../../modules/hardware/bluetooth.nix
    ../../modules/hardware/nvidia.nix
    ../../modules/hardware/logitech.nix

    ../../modules/home-manager.nix

    # ../../modules/gnome.nix
    ../../modules/hyprland.nix
    ../../modules/gaming.nix

    ../../modules/flatpack.nix
    ../../modules/1password.nix
    ../../modules/obs.nix
  ];

  networking.hostName = "asuka";

  system.stateVersion = "26.05";
}
