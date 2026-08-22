{ config, pkgs, ... }:

{
  age.secrets.lachlan-password.file = ../../../secrets/user-passwords/lachlan-password.age;

  users.users."lachlan" = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.lachlan-password.path;
    description = "Lachlan Malec";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
  home-manager.users."lachlan" = {
    imports = [
      ../../../modules/home/claude-code.nix
      ../../../modules/home/git.nix
      ../../../modules/home/helix.nix
      ../../../modules/home/development-csharp.nix
      ../../../modules/home/development-nix.nix
      ../../../modules/home/kitty.nix
      ../../../modules/home/zed-editor.nix
      ../../../modules/home/vesktop.nix
      ../../../modules/home/spotify.nix
      ../../../modules/home/google-chrome.nix
      ../../../modules/home/brave-origin.nix
      ../../../modules/home/slack.nix
      ../../../modules/home/shell.nix
      ../../../modules/home/tmux.nix
      ../../../modules/home/zellij.nix
    ];

    home.packages = with pkgs; [
      # General Dev Tools
      git
    ];

    home.stateVersion = "26.05";
  };
}
