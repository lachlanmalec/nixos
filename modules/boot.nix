{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    autoGenerateKeys.enable = true;
    autoEnrollKeys.enable = true;
  };

  local.persistence.systemDirectories = [
    "/var/lib/sbctl"
    "/var/lib/auto-cryptenroll" # lanzaboote secure boot key auto-enrollment
  ];

  boot.kernelModules = [ "ntsync" ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
