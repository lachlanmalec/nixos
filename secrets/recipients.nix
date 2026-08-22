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
  lachlan = "age1w7z9n7aahx9v8cxzkaem38ze3ah9vtq9mc4z63dc4e5ramnwwcdq7ksnpn";

  hosts = {
    kaworu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfSRbD/9VhCYcu8122grhjIxI9llm3Jbzb0PIdgxEW1";
    ritsuko = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPSTGeB9gtlzn0C+X6CbmyZ/Bkvt+jBA6Rw2bp3hJGH";
    asuka = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA2QrhgzuvtCjjsnvfL8tfQPsgELtOARqeM/aQcm8IvF";
  };
}
