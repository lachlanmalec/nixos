{ ... }:

{
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "lachlan" ];
  };

  home-manager.users."lachlan" = {
    home.sessionVariables = {
      SSH_AUTH_SOCK = "/home/lachlan/.1password/agent.sock";
    };
  };
}
