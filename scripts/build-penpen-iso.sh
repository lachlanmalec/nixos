#!/usr/bin/env bash
# Build the penpen live installer ISO with its root password baked in.
# The password hash lives age-encrypted in secrets/penpen-root-password.age;
# age prompts for the identity passphrase. The hash is injected into the
# build impurely, so the repo stays free of plaintext — but note the
# resulting image contains the hash: treat the ISO like the password.
#
#   scripts/build-penpen-iso.sh
#
# Output: ./result/iso/*.iso
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
identity=${AGE_IDENTITY:-$HOME/.config/age/keys.age}

PENPEN_ROOT_HASH=$(age -d -i "$identity" "$repo/secrets/penpen-root-password.age")
export PENPEN_ROOT_HASH

nix --extra-experimental-features 'nix-command flakes' build --impure "$repo#penpen-iso"

echo "ISO written to ./result/iso/"
