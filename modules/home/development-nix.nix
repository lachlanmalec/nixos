{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nil
    nixd
    package-version-server
  ];
}
