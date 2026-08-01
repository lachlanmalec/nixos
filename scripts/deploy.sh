#!/usr/bin/env bash
# Push-deploy a host, from any machine that holds the personal age key
# (~/.config/age/keys.age) and can reach the target over SSH:
#
#   scripts/deploy.sh <host> [ssh-target]     (ssh-target defaults to lachlan@<host>)
#
# If the host has a centrally-managed key (secrets/<host>-host-key.age), it
# is synced before the rebuild — so rotating a host key is just: rotate in
# secrets/, deploy. sshd is restarted, and the deployer's known_hosts entry
# re-pinned, only when the key actually changed.
#
# Deploying the machine you are running on rebuilds locally over sudo.
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
identity=${AGE_IDENTITY:-$HOME/.config/age/keys.age}
host=${1:?usage: deploy.sh <host> [ssh-target]}

blob="$repo/secrets/$host-host-key.age"

nixcmd() {
  nix --extra-experimental-features 'nix-command flakes' "$@"
}

# where this host reads its age identity — /persist/etc/ssh/... on
# ephemeral-root hosts, /etc/ssh/... otherwise; the host's own config is
# the authority
keyfile=$(nixcmd eval --raw \
  "$repo#nixosConfigurations.$host.config.age.identityPaths" \
  --apply 'paths: builtins.head paths')

tmp=$(mktemp -d)
cleanup() {
  shred -u "$tmp"/* 2>/dev/null || true
  rm -rf "$tmp"
}
trap cleanup EXIT

if [[ -f $blob ]]; then
  age -d -i "$identity" -o "$tmp/host.key" "$blob"
  chmod 600 "$tmp/host.key"
fi

if [[ $host == "$(uname -n)" ]]; then
  if [[ -f $blob ]] && ! sudo cmp -s "$tmp/host.key" "$keyfile"; then
    sudo install -D -m 600 "$tmp/host.key" "$keyfile"
    sudo systemctl try-restart sshd
    echo "deploy.sh: host key updated, sshd restarted"
  fi
  sudo nixos-rebuild switch --flake "$repo#$host"
  exit
fi

target=${2:-lachlan@$host}

if [[ -f $blob ]]; then
  # the target must present exactly this key — pin it, so a rotation (sshd
  # restart below) doesn't fail verification mid-deploy
  hostpart=${target#*@}
  pubkey=$(ssh-keygen -y -f "$tmp/host.key")
  ssh-keygen -R "$hostpart" > /dev/null 2>&1 || true
  echo "$hostpart $pubkey" >> ~/.ssh/known_hosts

  # sync the host key (idempotent); -t gives sudo a tty for its prompt
  scp -q "$tmp/host.key" "$target:/tmp/host.key"
  ssh -t "$target" "sudo sh -c '
    if ! cmp -s /tmp/host.key $keyfile; then
      install -D -m 600 /tmp/host.key $keyfile
      systemctl try-restart sshd
      echo \"deploy.sh: host key updated, sshd restarted\"
    fi
    shred -u /tmp/host.key
  '"
fi

NIX_SSHOPTS="-t" nixcmd shell nixpkgs#nixos-rebuild -c nixos-rebuild switch \
  --flake "$repo#$host" --target-host "$target" --use-remote-sudo
