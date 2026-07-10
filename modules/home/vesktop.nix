{ pkgs, ... }:

{
  home.packages = [ pkgs.vesktop ];

  # vesktop (settings and discord session)
  local.persistence.directories = [
    {
      directory = ".config/vesktop";
      mode = "0700";
    }
  ];
}
