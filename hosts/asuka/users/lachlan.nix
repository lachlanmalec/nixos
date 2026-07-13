{ pkgs, ... }:

{
  users.users."lachlan" = {
    isNormalUser = true;
    initialPassword = "password123";
    description = "Lachlan Malec";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
  home-manager.users."lachlan" = {
    imports = [
      ../../../modules/home/claude-code.nix
      ../../../modules/home/helix.nix
      ../../../modules/home/development-csharp.nix
      ../../../modules/home/development-nix.nix
      ../../../modules/home/kitty.nix
      ../../../modules/home/zed-editor.nix
      ../../../modules/home/vesktop.nix
      ../../../modules/home/spotify.nix
      ../../../modules/home/google-chrome.nix
      ../../../modules/home/slack.nix
    ];

    home.packages = with pkgs; [
      # General Dev Tools
      git
      gh
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
