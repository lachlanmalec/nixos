{ ... }:

{
  users.users."lachlan" = {
    isNormalUser = true;
    initialPassword = "password123";
    description = "Lachlan Malec";
    extraGroups = [
      "wheel"
    ];
  };
  home-manager.users."lachlan" = {
    imports = [
      ../../../modules/home/helix.nix
      ../../../modules/home/development-nix.nix
    ];

    programs.bash.enable = true;
    programs.starship.enable = true;
    programs.eza.enable = true;

    programs.tmux = {
      enable = true;
      mouse = true;
    };

    programs.git = {
      enable = true;
      settings.user.name = "Lachlan Malec";
      settings.user.email = "lachlan@lachlanmalec.dev";
    };

    home.stateVersion = "26.05";
  };
}
