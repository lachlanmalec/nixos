{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tmux
    neovim
    helix
    wget
    git
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.firefox.enable = true;

  services.openssh.enable = true;
}
