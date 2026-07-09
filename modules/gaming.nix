{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    protonup-qt
    mangohud
  ];
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  programs.steam = {
    remotePlay.openFirewall = true;
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  local.persistence.userDirectories = [
    # steam (includes proton prefixes and compatibilitytools.d)
    ".steam"
    ".local/share/Steam"

    # protonup-qt
    ".config/pupgui"
  ];
}
