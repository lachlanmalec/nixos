{ ... }:

{
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # persist each user's gnupg keyring and trust database
  local.persistence.userDirectories = [
    {
      directory = ".gnupg";
      mode = "0700";
    }
  ];
}
