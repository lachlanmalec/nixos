{ ... }:

{
  services.openssh = {
    enable = true;
    # root may log in with keys only, never a password
    settings.PermitRootLogin = "prohibit-password";
  };

  # keep host keys stable across root-subvolume rollbacks so clients
  # don't see host-key-changed warnings
  local.persistence.systemDirectories = [
    "/etc/ssh"
  ];
}
