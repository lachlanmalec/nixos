{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tmux
    neovim
    helix
    wget
    git
  ];

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
    # nixos
    {
      directory = ".config/nixos";
      mode = "0700";
    }
  ];
}
