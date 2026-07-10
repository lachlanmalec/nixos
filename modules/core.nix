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

  # base os state
  local.persistence.systemFiles = [
    {
      file = "/etc/machine-id";
      inInitrd = true;
    }
  ];
  local.persistence.systemDirectories = [
    "/var/lib/systemd/timers"
    "/var/lib/nixos"
    "/var/log"
  ];

  local.persistence.userDirectories = [
    # firefox
    {
      directory = ".config/mozilla";
      mode = "0700";
    }
    # nixos
    {
      directory = ".config/nixos";
      mode = "0700";
    }
  ];
}
