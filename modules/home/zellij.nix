{ ... }:

{
  programs.zellij.enable = true;

  # zellij (session resurrection data and granted plugin permissions)
  local.persistence.directories = [
    ".cache/zellij"
  ];
}
