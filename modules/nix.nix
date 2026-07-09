{ ... }:

{
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  local.persistence.systemDirectories = [
    "/etc/nixos"
  ];
}
