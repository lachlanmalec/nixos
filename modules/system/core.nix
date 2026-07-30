{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    tmux
    neovim
    helix
    wget
    git
  ];

  # base os state
  local.persistence.systemFiles = [
    {
      file = "/etc/machine-id";
      inInitrd = true;
    }
  ];
  local.persistence.systemDirectories = [
    "/etc/nixos"
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
