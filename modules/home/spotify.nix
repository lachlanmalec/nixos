{ pkgs, ... }:

{
  home.packages = [ pkgs.spotify ];

  # spotify (login and settings; cache stays ephemeral)
  local.persistence.directories = [
    {
      directory = ".config/spotify";
      mode = "0700";
    }
  ];
}
