{ ... }:

{
  networking.hostName = "asuka";
  networking.networkmanager.enable = true;

  # bluetooth (org.bluez); state persisted below in /var/lib/bluetooth
  hardware.bluetooth.enable = true;

  # imperative connectivity
  local.persistence.systemDirectories = [
    "/var/lib/bluetooth"
    "/etc/NetworkManager/system-connections"
  ];

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
}
