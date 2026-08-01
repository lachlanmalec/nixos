#!/usr/bin/env bash
# First install of a host with nixos-anywhere, from any machine that holds
# the personal age key (~/.config/age/keys.age): boot the target from a
# stock NixOS installer ISO, give it a way in (`sudo passwd` on the live
# system), then run:
#
#   scripts/provision.sh <host> root@<installer-ip> [extra nixos-anywhere args]
#
# Beyond formatting (disko) and installing, this seeds /persist before the
# first boot — preservation's bind-mount sources, lachlan's home, and the
# host's SSH key (the age identity). Skipping that seeding is what could
# brick secure boot on a headless machine: sbctl keys enrolled from a
# volatile root are destroyed by the first rollback.
#
# After the first boot, confirm `systemctl --failed` shows no preservation
# mounts and /persist/var/lib/sbctl exists BEFORE putting firmware into
# setup mode to enroll secure-boot keys.
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
identity=${AGE_IDENTITY:-$HOME/.config/age/keys.age}
host=${1:?usage: provision.sh <host> root@<installer-ip> [extra args]}
target=${2:?usage: provision.sh <host> root@<installer-ip> [extra args]}
shift 2

tmp=$(mktemp -d)
cleanup() {
  find "$tmp" -type f -exec shred -u {} + 2>/dev/null || true
  rm -rf "$tmp"
}
trap cleanup EXIT

# preservation bind-mount sources that must exist before boot 1 (their
# tmpfiles rules only run after the mount attempts)
extra="$tmp/extra-files"
mkdir -p \
  "$extra/persist/etc/ssh" \
  "$extra/persist/etc/nixos" \
  "$extra/persist/var/log" \
  "$extra/persist/var/lib/nixos" \
  "$extra/persist/var/lib/sbctl" \
  "$extra/persist/var/lib/auto-cryptenroll" \
  "$extra/persist/var/lib/systemd/timers" \
  "$extra/persist/home/lachlan/.config/nixos"
chmod 700 "$extra/persist/home/lachlan/.config/nixos"

age -d -i "$identity" -o "$extra/persist/etc/ssh/ssh_host_ed25519_key" \
  "$repo/secrets/$host-host-key.age"
chmod 600 "$extra/persist/etc/ssh/ssh_host_ed25519_key"

# regenerated hardware config must be git-tracked for the flake build to
# see it
touch "$repo/hosts/$host/hardware-configuration.nix"
git -C "$repo" add --intent-to-add "hosts/$host/hardware-configuration.nix" || true

nix --extra-experimental-features 'nix-command flakes' run nixpkgs#nixos-anywhere -- \
  --flake "$repo#$host" \
  --extra-files "$extra" \
  --chown /persist/home/lachlan 1000:100 \
  --generate-hardware-config nixos-generate-config "$repo/hosts/$host/hardware-configuration.nix" \
  "$@" \
  "$target"
