{ pkgs, ... }:

{
  home.packages = [ pkgs.google-chrome ];

  # google-chrome (profiles, logins, extensions; cache stays ephemeral)
  local.persistence.directories = [
    {
      directory = ".config/google-chrome";
      mode = "0700";
    }
  ];
}
