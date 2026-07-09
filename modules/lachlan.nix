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
    home.packages = with pkgs; [
      vesktop
      spotify

      # General Dev Tools
      zed-editor
      claude-code
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

    home.sessionVariables = {
      CLAUDE_CONFIG_DIR = "/home/lachlan/.config/claude";
    };

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
