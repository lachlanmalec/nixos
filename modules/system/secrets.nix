{
  config,
  pkgs,
  inputs,
  ...
}:

let
  recipients = import ../../secrets/recipients.nix;
  hostName = config.networking.hostName;
  hostKey = recipients.hosts.${hostName} or null;

  # agenix decrypts during activation, which runs before preservation's
  # stage-2 bind mounts on boot — so on ephemeral-root hosts the identity
  # must be read from (and installed to) the /persist source, never the
  # /etc/ssh mount point
  identityFile =
    if config.local.persistence.enable then
      "/persist/etc/ssh/ssh_host_ed25519_key"
    else
      "/etc/ssh/ssh_host_ed25519_key";
in
{
  # a host whose recipient key is missing would deploy fine but fail to
  # decrypt its secrets at activation — on an ephemeral-root host that can
  # mean a login lockout; refuse to evaluate instead
  assertions = [
    {
      assertion = hostKey != null;
      message = ''
        secrets/recipients.nix has no age recipient for host "${hostName}".
        Mint one (see the README at the repo root), then re-encrypt the secrets:
          cd secrets && agenix -r -i ~/.config/age/keys.age
      '';
    }
  ];

  # the managed host key is the only identity — placed and rotated by the
  # push tooling (scripts/provision.sh seeds it at install, scripts/
  # deploy.sh syncs it before every rebuild); the config only ever reads
  # it. lachlan's personal key is deliberately NOT listed: it is
  # passphrase-protected (~/.config/age/keys.age) and activation cannot
  # prompt for a passphrase
  age.identityPaths = [ identityFile ];

  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.age
  ];

  # personal age identity used to edit/rekey secrets
  local.persistence.userDirectories = [
    {
      directory = ".config/age";
      mode = "0700";
    }
  ];
}
