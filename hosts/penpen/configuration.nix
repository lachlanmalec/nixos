{ lib, ... }:

let
  # injected by scripts/build-penpen-iso.sh (nix build --impure); the hash
  # lives age-encrypted in secrets/penpen-root-password.age. It is baked
  # into the ISO — the image itself is as sensitive as the password.
  rootHash = builtins.getEnv "PENPEN_ROOT_HASH";
in
{
  # everything else is the stock minimal installer ISO — the profile is
  # imported in flake.nix
  networking.hostName = "penpen";
  nixpkgs.hostPlatform = "x86_64-linux";

  assertions = [
    {
      assertion = rootHash != "";
      message = ''
        PENPEN_ROOT_HASH is not set. Build this ISO with
        scripts/build-penpen-iso.sh — it decrypts the root password hash
        from secrets/penpen-root-password.age and injects it into the
        (impure) build.
      '';
    }
  ];

  # the installer profile presets an empty root password; override this
  users.users.root.initialHashedPassword = lib.mkForce rootHash;

  system.stateVersion = "26.05";
}
