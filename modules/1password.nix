{ ... }:

{
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "lachlan" ];
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

  home-manager.users."lachlan" = {
    home.sessionVariables = {
      SSH_AUTH_SOCK = "/home/lachlan/.1password/agent.sock";
    };
  };
}
