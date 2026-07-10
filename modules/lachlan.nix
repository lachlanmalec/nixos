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
      ./home/claude-code.nix
      ./home/zed-editor.nix
      ./home/vesktop.nix
    ];

    home.packages = with pkgs; [
      spotify
      google-chrome

      # General Dev Tools
      git
      gh
      
      # C# Dev Tools
      dotnet-sdk_10
      csharp-ls
            
      # Nix Development Tools
      nil
      nixd
      package-version-server
    ];

    programs.bash.enable = true;
    programs.starship.enable = true;
    programs.eza.enable = true;

    programs.helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        theme = "github_dark";
      };
    };

    programs.tmux = {
      enable = true;
      mouse = true;
    };

    home.stateVersion = "26.05";
  };
}
