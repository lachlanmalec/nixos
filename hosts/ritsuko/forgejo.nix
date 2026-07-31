{ ... }:

{
  services.forgejo = {
    enable = true;
    database.type = "sqlite3";
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = "git.ritsuko.local";
        ROOT_URL = "http://git.ritsuko.local/";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 3030;
      };
      actions.ENABLED = false;
      mailer.ENABLED = false;
      service.DISABLE_REGISTRATION = true;
    };
  };

  # repositories, LFS objects and the sqlite database all live in the
  # forgejo state directory
  local.persistence.systemDirectories = [
    "/var/lib/forgejo"
  ];

  services.nginx.virtualHosts."git.ritsuko.local" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:3030";
    };
    # git pushes and LFS objects blow past nginx's 10M default body limit
    extraConfig = ''
      client_max_body_size 512m;
    '';
  };
}
