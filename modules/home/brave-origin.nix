{ pkgs, ... }:

{
  home.packages = [ pkgs.brave-origin ];

  # brave-origin (profiles, logins, extensions; cache stays ephemeral)
  local.persistence.directories = [
    {
      directory = ".config/BraveSoftware/Brave-Origin";
      mode = "0700";
    }
  ];
}
