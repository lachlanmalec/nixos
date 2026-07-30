{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./disko.nix
    ./seed-config.nix
    ./users/lachlan.nix

    ../../modules/system/core.nix
    ../../modules/system/persistence.nix
    ../../modules/system/ssh.nix
    ../../modules/system/home-manager.nix

    ../../modules/locales/australia-brisbane.nix
    ../../modules/network-manager.nix
  ];

  networking.hostName = "penpen";

  # portable UEFI boot: never touch the host machine's NVRAM; bootctl then
  # also installs the removable-media fallback loader (\EFI\BOOT\BOOTX64.EFI)
  # so any UEFI firmware can boot the stick
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  local.persistence.enable = true;
  local.persistence.mode = "tmpfs-root";

  # a roaming rescue stick joins untrusted networks: key-only SSH
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.KbdInteractiveAuthentication = false;

  # /var/db/sudo is on the tmpfs root; don't re-lecture every boot
  security.sudo.extraConfig = "Defaults lecture = never";

  # deploy tooling for reinstalling other hosts from the stick
  environment.systemPackages = [
    inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
    pkgs.nixos-anywhere
  ];

  # the pinned disko passes a kernel-modules tree as vmTools' `kernel`
  # argument, which this nixpkgs rejects at eval time; reroute it to the
  # new `kernelModules` argument with a real kernel. Scoped to the image
  # builder only — remove once disko catches up with the vmTools interface.
  disko.imageBuilder.pkgs = pkgs.extend (
    _final: prev: {
      vmTools = prev.vmTools // {
        override =
          args:
          prev.vmTools.override (
            args
            // lib.optionalAttrs (args ? kernel) {
              kernel = config.boot.kernelPackages.kernel;
              kernelModules = args.kernel;
            }
          );
      };
    }
  );

  system.stateVersion = "26.05";
}
