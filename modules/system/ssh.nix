{ ... }:

{
  services.openssh = {
    enable = true;
    # root may log in with keys only, never a password
    settings.PermitRootLogin = "prohibit-password";
    # ed25519 only — it is the age decryption identity, and there is no
    # reason to also offer an RSA host key
    hostKeys = [
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ed25519_key";
      }
    ];
  };

  # keep host keys stable across root-subvolume rollbacks so clients
  # don't see host-key-changed warnings
  local.persistence.systemDirectories = [
    "/etc/ssh"
  ];
}
