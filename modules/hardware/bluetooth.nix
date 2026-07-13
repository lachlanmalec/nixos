{ ... }:

{
  # bluetooth (org.bluez); state persisted below in /var/lib/bluetooth
  hardware.bluetooth.enable = true;

  local.persistence.systemDirectories = [
    "/var/lib/bluetooth"
  ];
}
