{
  home-manager.users.grafana =
    { pkgs, ... }:
    let
      prometheusConfig = pkgs.writeText "prometheus.yml" ''
        global:
          scrape_interval: 30s
          scrape_timeout: 10s

        scrape_configs:
          - job_name: crowdsec
            static_configs:
              - targets:
                  - 100.69.69.201:6060
                labels:
                  host: pangolin

          - job_name: prometheus
            static_configs:
              - targets:
                  - localhost:9090
      '';

      grafanaDatasources = pkgs.writeText "datasources.yml" ''
        apiVersion: 1
        datasources:
          - name: Prometheus
            uid: prometheus
            type: prometheus
            access: proxy
            url: http://prometheus:9090
            isDefault: true
            editable: false
      '';

      grafanaDashboardProvider = pkgs.writeText "dashboards.yml" ''
        apiVersion: 1
        providers:
          - name: security
            folder: Security
            type: file
            options:
              path: /etc/grafana/dashboards
      '';
    in
    {
      home.stateVersion = "25.05";

      services.podman = {
        enable = true;

        networks.monitoring = { };

        containers.prometheus = {
          image = "docker.io/prom/prometheus@sha256:1f0f50f06acaceb0f5670d2c8a658a599affe7b0d8e78b898c1035653849a702";
          autoStart = true;
          autoUpdate = "registry";
          network = "monitoring.network";
          networkAlias = [ "prometheus" ];
          exec = "--config.file=/etc/prometheus/prometheus.yml --storage.tsdb.retention.time=90d";
          volumes = [
            "${prometheusConfig}:/etc/prometheus/prometheus.yml:ro"
            "/var/lib/grafana/prometheus:/prometheus:U"
          ];
          extraConfig = {
            Container = {
              DropCapability = "ALL";
              NoNewPrivileges = true;
              ReadOnly = true;
            };
            Service.Restart = "always";
          };
        };

        containers.grafana = {
          image = "docker.io/grafana/grafana@sha256:26b8f35a9e4e4431995cf64c3f396505a4faf17bcfc19f9ed84943ec6bfd5ecd";
          autoStart = true;
          autoUpdate = "registry";
          network = "monitoring.network";
          ports = [ "127.0.0.1:3030:3000" ];
          volumes = [
            "${grafanaDatasources}:/etc/grafana/provisioning/datasources/datasources.yml:ro"
            "${grafanaDashboardProvider}:/etc/grafana/provisioning/dashboards/dashboards.yml:ro"
            "${./crowdsec-dashboard.json}:/etc/grafana/dashboards/crowdsec.json:ro"
            "/var/lib/grafana/data:/var/lib/grafana:U"
          ];
          environment = {
            GF_ANALYTICS_REPORTING_ENABLED = "false";
            GF_ANALYTICS_CHECK_FOR_UPDATES = "false";
            GF_SECURITY_DISABLE_GRAVATAR = "true";
            GF_USERS_ALLOW_SIGN_UP = "false";
          };
          environmentFile = [ "/run/secrets/grafana.env" ];
          extraConfig = {
            Container = {
              DropCapability = "ALL";
              NoNewPrivileges = true;
              ReadOnly = true;
            };
            Service.Restart = "always";
            Unit = {
              After = [ "podman-prometheus.service" ];
              Wants = [ "podman-prometheus.service" ];
            };
          };
        };
      };
    };

  age.secrets."grafana.env" = {
    file = ../../../../../secrets/srv-n1.grafana.env.age;
    path = "/run/secrets/grafana.env";
    owner = "grafana";
    group = "grafana";
    mode = "0400";
  };
}
