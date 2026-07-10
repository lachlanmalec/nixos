{ pkgs, config, ... }:

{
  home.packages = [ pkgs.claude-code ];

  home.sessionVariables = {
    CLAUDE_CONFIG_DIR = "${config.xdg.configHome}/claude";
  };

  # claude code (settings, history, credentials)
  local.persistence.directories = [
    {
      directory = ".config/claude";
      mode = "0700";
    }
  ];
}
