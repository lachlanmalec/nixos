{ pkgs, ... }:

{
  hardware.logitech.wireless.enable = true;
  environment.systemPackages = with pkgs; [ solaar ];

  # solaar (logitech device settings and rules)
  local.persistence.userDirectories = [
    ".config/solaar"
  ];
}
