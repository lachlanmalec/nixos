{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/disko.nix
    ./modules/boot.nix
    ./modules/nix.nix
    ./modules/core.nix
    ./modules/persistence.nix
    ./modules/locale.nix
    ./modules/network.nix

    ./modules/audio.nix
    ./modules/graphics.nix
    ./modules/logitech.nix

    ./modules/home-manager.nix

    # ./modules/gnome.nix
    ./modules/hyprland.nix
    ./modules/gaming.nix
    ./modules/lachlan.nix

    ./modules/flatpack.nix
    ./modules/1password.nix
    ./modules/obs.nix
  ];

  system.stateVersion = "26.05";
}
