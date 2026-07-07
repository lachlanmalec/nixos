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
}
