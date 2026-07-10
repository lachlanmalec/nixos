{ config, lib, ... }:

let
  normalUsers = lib.filterAttrs (_: u: u.isNormalUser) config.users.users;
in
{
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # every normal user may unlock 1password via system authentication
    polkitPolicyOwners = builtins.attrNames normalUsers;
  };

  local.persistence.userDirectories = [
    {
      directory = ".config/1Password";
      mode = "0700";
    }
    {
      directory = ".config/op";
      mode = "0700";
    }
  ];

  # use the 1password agent for ssh in every user session
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        home.sessionVariables = {
          SSH_AUTH_SOCK = "${config.home.homeDirectory}/.1password/agent.sock";
        };
      }
    )
  ];
}
