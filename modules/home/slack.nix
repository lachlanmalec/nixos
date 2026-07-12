{ pkgs, ... }:

{
  home.packages = [ pkgs.slack ];

  # slack (login, workspaces, and settings; cache stays ephemeral)
  local.persistence.directories = [
    {
      directory = ".config/Slack";
      mode = "0700";
    }
  ];
}
