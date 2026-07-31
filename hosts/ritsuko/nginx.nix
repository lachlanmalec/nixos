{ ... }:

{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  # nginx itself keeps no state worth persisting: access/error logs land in
  # /var/log/nginx (already persisted via core.nix) and caches are rebuilt
  # at runtime
}
