{ ... }:

{
  networking.hostName = "asuka";
  networking.networkmanager.enable = true;

  # imperative connectivity
  local.persistence.systemDirectories = [
    "/etc/NetworkManager/system-connections"
  ];

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
}
