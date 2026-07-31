{ ... }:

{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "grafana.ritsuko.local";
        root_url = "http://grafana.ritsuko.local/";
      };
      # required by the module; plaintext until age-based secrets land
      security.secret_key = "changeme-until-age-secrets";
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
          isDefault = true;
        }
        {
          name = "Loki";
          type = "loki";
          url = "http://127.0.0.1:3100";
        }
      ];
    };
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    retentionTime = "90d";
    exporters.node = {
      enable = true;
      listenAddress = "127.0.0.1";
    };
    exporters.nginx = {
      enable = true;
      listenAddress = "127.0.0.1";
    };
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [ { targets = [ "127.0.0.1:9090" ]; } ];
      }
      {
        job_name = "node";
        static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
      }
      {
        job_name = "nginx";
        static_configs = [ { targets = [ "127.0.0.1:9113" ]; } ];
      }
      {
        job_name = "forgejo";
        static_configs = [ { targets = [ "127.0.0.1:3030" ]; } ];
      }
    ];
  };

  # the nginx exporter reads nginx's stub_status endpoint
  services.nginx.statusPage = true;

  # expose forgejo's /metrics for the scrape job above
  services.forgejo.settings.metrics.ENABLED = true;

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = 3100;
        grpc_listen_address = "127.0.0.1";
      };
      common = {
        replication_factor = 1;
        ring = {
          kvstore.store = "inmemory";
          instance_addr = "127.0.0.1";
        };
        path_prefix = "/var/lib/loki";
      };
      schema_config.configs = [
        {
          from = "2026-01-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];
      storage_config.filesystem.directory = "/var/lib/loki/chunks";
      compactor = {
        # loki's flag default is /var/loki/compactor — outside the
        # persisted state directory; retention bookkeeping must survive
        # reboots
        working_directory = "/var/lib/loki/compactor";
        retention_enabled = true;
        delete_request_store = "filesystem";
      };
      limits_config.retention_period = "90d";
    };
  };

  services.alloy.enable = true;
  environment.etc."alloy/config.alloy".text = ''
    loki.source.journal "journal" {
      forward_to = [loki.write.local.receiver]
    }

    loki.write "local" {
      endpoint {
        url = "http://127.0.0.1:3100/loki/api/v1/push"
      }
    }
  '';

  # dashboards/users (grafana), TSDB blocks (prometheus), log chunks and
  # index (loki), and journal read positions (alloy) all live under
  # /var/lib
  local.persistence.systemDirectories = [
    "/var/lib/grafana"
    "/var/lib/prometheus2"
    "/var/lib/loki"
    "/var/lib/alloy"
  ];

  services.nginx.virtualHosts."grafana.ritsuko.local" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:3000";
      # Grafana Live streams over websockets
      proxyWebsockets = true;
    };
  };
}
