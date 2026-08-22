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
      ../../../modules/home/git.nix
      ../../../modules/home/helix.nix
      ../../../modules/home/development-nix.nix
      ../../../modules/home/shell.nix
      ../../../modules/home/tmux.nix
      ../../../modules/home/zellij.nix
    ];

    # minimal server host: no gh/GitHub CLI or fj/Forgejo CLI needed
    local.git.enableGithubCli = false;
    local.git.enableForgejoCli = false;

    home.stateVersion = "26.05";
  };
}
