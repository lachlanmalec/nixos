{ ... }:

{
  networking.networkmanager.enable = true;

  # imperative connectivity
  local.persistence.systemDirectories = [
    "/etc/NetworkManager/system-connections"
  ];
}
