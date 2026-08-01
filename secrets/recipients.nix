# Single source of truth for age recipients. Consumed by secrets.nix (the
# agenix CLI ruleset) and by modules/system/secrets.nix, which refuses to
# evaluate a host whose key is null — so a host can never deploy in a state
# where its secrets are undecryptable.
#
# Deployments are push-style, from any machine that holds lachlan's
# personal age key (~/.config/age/keys.age): scripts/provision.sh installs
# a machine from a stock NixOS installer with nixos-anywhere (seeding
# /persist and the host key), and scripts/deploy.sh pushes rebuilds —
# syncing the host key first, so rotating a key is just: rotate here,
# deploy. Procedures: the README at the repo root.
{
  # lachlan's personal key (age-keygen); private half at
  # ~/.config/age/keys.age, passphrase-protected — raw key and passphrase
  # backed up on 1password
  lachlan = "age1d4ckr3qw93hs04mppzfma7rgd04mac76ea2fy6ymkm7g58fy2v8s0w7pzh";

  hosts = {
    kaworu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7lr2mEJovSkTh6Kx88Jg15kMLAgMYJ0L9Ni0lQWRtX";
    ritsuko = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM5vizfxkjZRxKygGtFXhuRMRzQrbHUEkKckmvJUy24d";
    asuka = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEzJOwe3lfHsl2GGCcIIbCzzSuGEVq2CJxs4oLGJVv2";
  };
}
