{ ... }:

{
  programs.firefox.enable = true;

  local.persistence.userDirectories = [
    {
      directory = ".config/mozilla";
      mode = "0700";
    }
  ];
}
