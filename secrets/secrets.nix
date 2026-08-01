# Ruleset for the agenix CLI (run from this directory):
#   agenix -e <name>.age -i ~/.config/age/keys.age   # create/edit a secret
#   agenix -r -i ~/.config/age/keys.age              # re-encrypt after recipient changes
# Key/secret rotation procedures: see the README at the repo root.
let
  recipients = import ./recipients.nix;

  unique = builtins.foldl' (acc: x: if builtins.elem x acc then acc else acc ++ [ x ]) [ ];

  # every secret is readable by lachlan (for editing/rekeying) plus the hosts
  # that need it; hosts whose key is still null are skipped until filled in
  forHosts =
    names:
    unique (
      [ recipients.lachlan ]
      ++ builtins.filter (k: k != null) (map (h: recipients.hosts.${h}) names)
    );
in
{
  # yescrypt hash of lachlan's login password (mkpasswd -m yescrypt)
  "lachlan-password.age".publicKeys = forHosts [
    "kaworu"
    "ritsuko"
    "asuka"
  ];

  # grafana server-side signing/encryption key (security.secret_key)
  "ritsuko-grafana-secret-key.age".publicKeys = forHosts [ "ritsuko" ];

  # centrally-minted SSH host keys — readable only by lachlan; the deploy
  # tooling decrypts and pushes them onto the machines (provision.sh at
  # install, deploy.sh on every rebuild), and they double as identity
  # backups if a /persist is ever lost
  "kaworu-host-key.age".publicKeys = forHosts [ ];
  "ritsuko-host-key.age".publicKeys = forHosts [ ];
  "asuka-host-key.age".publicKeys = forHosts [ ];
}
