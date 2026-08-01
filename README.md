# NixOS Configuration

Flake-based NixOS configuration for all of lachlan's machines. Hosts run
ephemeral roots with selective persistence to `/persist` (via
[preservation](https://github.com/nix-community/preservation)), disks are
declared with [disko](https://github.com/nix-community/disko), and secrets
are age-encrypted with [agenix](https://github.com/ryantm/agenix).
Deployments are push-style: machines are installed with nixos-anywhere and
updated with `nixos-rebuild --target-host`, driven by the scripts in
`scripts/`.

## Structure

- `flake.nix` — inputs and one `nixosConfiguration` per host
- `hosts/` — per-host configuration
  - `asuka` — desktop (Hyprland, gaming, nvidia)
  - `kaworu` — WSL development machine
  - `ritsuko` — headless server (nginx, forgejo, grafana/prometheus/loki)
- `modules/` — shared modules
  - `system/` — base system: persistence (ephemeral root), secrets,
    ssh, boot (lanzaboote secure boot), core
  - `home/` — per-application home-manager modules
  - `hardware/`, `locales/` and desktop/app modules
- `secrets/` — age-encrypted secrets, the recipient list
  (`recipients.nix`), and the agenix ruleset (`secrets.nix`)
- `scripts/` — `provision.sh` (first install) and `deploy.sh` (rebuilds)

## Deployment and secret rotation

Everything below runs on any machine that holds lachlan's personal age key
at `~/.config/age/keys.age` and can reach the targets over SSH — every
host persists `~/.config/age`, so any of them can act as the deployer once
the key file is copied there. The key file is itself age-encrypted with a
passphrase (`age -p`), so age prompts for it on every use — a leaked file
alone buys an attacker nothing until the passphrase falls. The raw key and
the passphrase are backed up in 1Password. `agenix` and `age` are in
`environment.systemPackages` on every host; elsewhere prefix with
`nix shell nixpkgs#age` / `nix run github:ryantm/agenix --`.

Scripts run from the repo root; `agenix` commands run in `secrets/`. A
shorthand used throughout:

```sh
alias agenix='agenix -i ~/.config/age/keys.age'
```

### The model

Deployments are push-style:

- `scripts/provision.sh <host> root@<installer-ip>` — first install via
  nixos-anywhere from a stock NixOS installer ISO. Formats with disko and
  seeds `/persist` before the first boot: preservation's bind-mount
  sources, lachlan's home, and the host's SSH key. The host key is the
  machine's age identity; reusing the committed `<host>-host-key.age`
  means a reinstall keeps the machine's SSH identity and needs no rekeying.
- `scripts/deploy.sh <host>` — every subsequent rebuild. If the host has a
  managed key (`secrets/<host>-host-key.age`), it is synced first
  (restarting sshd only if it changed), then `nixos-rebuild switch
  --target-host` runs. Deploying the machine you are on rebuilds locally.

Hosts never fetch or install keys themselves; the config only *reads* the
identity at `/persist/etc/ssh/ssh_host_ed25519_key` (`/etc/ssh/...` on
hosts without impermanence — note the /persist path matters: agenix
decrypts during activation, before preservation's stage-2 bind mounts, so
the `/etc/ssh` view doesn't exist yet at boot).

### Rotating a secret value

For a compromised or aging secret (password, grafana key, …):

```sh
agenix -e lachlan-password.age        # opens $EDITOR on the plaintext
# for the password specifically, paste the output of:
mkpasswd -m yescrypt
```

Then `scripts/deploy.sh` the affected hosts. Rotating a *value* needs no
recipient changes.

### Rotating lachlan's personal age key

This key is the root of trust: it can read every secret including the host
keys. Rotate it if it may have leaked, or on general hygiene.

1. Generate the new key alongside the old one (plaintext, temporarily):

   ```sh
   age-keygen -o /tmp/keys-new.txt
   ```

2. Put the new public key (printed by `age-keygen`, or
   `age-keygen -y /tmp/keys-new.txt`) into `recipients.nix` as `lachlan`.

3. Re-encrypt everything while the **old** key can still decrypt:

   ```sh
   agenix -r     # i.e. agenix -r -i ~/.config/age/keys.age (old key)
   ```

4. Verify with the new key before destroying anything:

   ```sh
   age -d -i /tmp/keys-new.txt lachlan-password.age > /dev/null && echo ok
   ```

5. Passphrase-encrypt it into place, verify the result unlocks, and only
   then shred the plaintext and the old key:

   ```sh
   age -p -a -o ~/.config/age/keys.age /tmp/keys-new.txt
   age -d ~/.config/age/keys.age | age-keygen -y   # must print the new pubkey
   shred -u /tmp/keys-new.txt
   ```

6. Update the 1Password backup (raw key and passphrase).

If the old key was *compromised* (not just aged out), also rotate every
secret value and every host key: re-encrypting only protects future
ciphertexts — whoever held the old key could already have read the current
plaintexts.

### Rotating a host key

1. Mint the new keypair and put it in the blob and the recipients:

   ```sh
   ssh-keygen -t ed25519 -N "" -C root@ritsuko -f /tmp/hk
   # paste /tmp/hk.pub (drop the comment) into recipients.nix hosts.<host>
   EDITOR="cp /tmp/hk" agenix -e ritsuko-host-key.age
   agenix -r
   shred -u /tmp/hk /tmp/hk.pub
   ```

2. Deploy — the key sync in deploy.sh installs the new key and restarts
   sshd before the rebuild, so the activation decrypts with the new
   identity already in place. It also re-pins the host's entry in the
   deployer's `known_hosts` (it knows the correct key — no TOFU prompt):

   ```sh
   scripts/deploy.sh ritsuko
   ```

3. Other machines' `known_hosts` entries need re-approving on next
   connect (the SSH identity changed).

A host acting as the deployer additionally holds `~/.config/age/keys.age`.
It is not an activation identity (hosts decrypt only with their managed
host key — a passphrase prompt has no place in a rebuild), so it can be
copied to or removed from any machine at any time.
