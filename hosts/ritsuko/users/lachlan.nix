{ config, ... }:

{
  age.secrets.lachlan-password.file = ../../../secrets/lachlan-password.age;

  users.users."lachlan" = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.lachlan-password.path;
    description = "Lachlan Malec";
    extraGroups = [
      "wheel"
    ];
  };
  home-manager.users."lachlan" = {
    imports = [
      ../../../modules/home/helix.nix
      ../../../modules/home/development-nix.nix
      ../../../modules/home/shell.nix
      ../../../modules/home/tmux.nix
      ../../../modules/home/zellij.nix
    ];

    programs.git = {
      enable = true;
      settings.user.name = "Lachlan Malec";
      settings.user.email = "lachlan@lachlanmalec.dev";
    };

    home.stateVersion = "26.05";
  };
}
