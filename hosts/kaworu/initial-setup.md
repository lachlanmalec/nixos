# kaworu — initial setup on a fresh NixOS-WSL instance

Bootstrap steps to take a stock [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)
install to this repo's `kaworu` configuration. Nothing here is persistent —
git and the experimental-features flags are one-shot until the first switch
makes them part of the system.

## 1. Get git into the current shell temporarily

The fresh instance runs as the bootstrap `nixos` user:

```bash
sudo nix-channel --update    # once on a fresh install, so nix-shell can resolve packages
nix-shell -p git
```

This opens a subshell with `git` available; it is gone on `exit`.

## 2. Clone the repo

```bash
git clone https://github.com/lachlanmalec/nixos.git ~/nixos
cd ~/nixos
```

## 3. Switch to the kaworu configuration

Flakes and `nix-command` are enabled just for this one command (`sudo env`
carries the setting across sudo's environment reset):

```bash
sudo env NIX_CONFIG="extra-experimental-features = nix-command flakes" \
  nixos-rebuild switch --flake .#kaworu
```

The first run downloads/builds the whole system closure — expect it to take
a while. If it errors about not finding `git`, rerun with
`sudo --preserve-env=PATH env NIX_CONFIG=...` so root can see the nix-shell
git (recent Nix uses libgit2 and shouldn't need it).

## 4. Restart the distro from Windows

Required for `wsl.defaultUser = "lachlan"` and the `kaworu` hostname to take
effect:

```powershell
wsl -t NixOS     # or: wsl --shutdown
wsl -d NixOS
```

You'll land as `lachlan`. Change the placeholder password immediately:

```bash
passwd
```

## After the switch

- Flakes and `nix-command` are now permanently enabled by the config
  (`modules/system/core.nix`), so future rebuilds are just
  `sudo nixos-rebuild switch --flake .#kaworu` — no env prefix needed, and
  git is in the system packages.
- The clone ended up in the bootstrap user's home (`/home/nixos/nixos`).
  Reclaim it:

  ```bash
  mkdir -p ~/.config && sudo mv /home/nixos/nixos ~/.config/nixos && sudo chown -R lachlan:users ~/.config/nixos
  ```
