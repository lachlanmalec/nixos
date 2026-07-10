{ pkgs, ... }:

{
  home.packages = [ pkgs.zed-editor ];

  # zed-editor (settings; extensions, language servers and workspace state)
  local.persistence.directories = [
    ".config/zed"
    ".local/share/zed"
  ];
}
