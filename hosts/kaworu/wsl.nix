{ lib, ... }:

{
  wsl.enable = true;
  wsl.defaultUser = "lachlan";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
