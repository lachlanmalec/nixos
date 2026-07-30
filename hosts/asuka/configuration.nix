{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./users/lachlan.nix

    ../../modules/system/boot.nix
    ../../modules/system/core.nix
    ../../modules/system/gpg.nix
    ../../modules/system/persistence.nix
    ../../modules/system/ssh.nix
    ../../modules/system/home-manager.nix

    ../../modules/locales/australia-brisbane.nix
    ../../modules/firefox.nix
    ../../modules/network-manager.nix

    ../../modules/hardware/audio.nix
    ../../modules/hardware/bluetooth.nix
    ../../modules/hardware/nvidia.nix
    ../../modules/hardware/logitech.nix

    # ../../modules/gnome.nix
    ../../modules/hyprland.nix
    ../../modules/gaming.nix

    ../../modules/flatpack.nix
    ../../modules/1password.nix
    ../../modules/obs.nix
  ];

  networking.hostName = "asuka";

  local.persistence.enable = true;

  system.stateVersion = "26.05";
}
