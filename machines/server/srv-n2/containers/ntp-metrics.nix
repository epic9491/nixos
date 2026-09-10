{
  home-manager.users.metrics = _: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;

      # chronyd only binds its command port on loopback, so these share the host netns
      containers.chrony-exporter = {
        image = "quay.io/superq/chrony-exporter:v0.14.0@sha256:74c7294e79dff4e6eaa48129a69a6da353a0d321f26bd315dcb682f6200c0fd1";
        autoStart = true;
        network = "host";
        exec = "--chrony.address=127.0.0.1:323 --collector.serverstats --collector.sources --collector.sourcestats --no-collector.dns-lookups --web.listen-address=:9123";
        extraConfig = {
          Container = {
            DropCapability = "ALL";
            NoNewPrivileges = true;
            ReadOnly = true;
          };
          Service.Restart = "always";
        };
      };

      # the client log comes back 8 records a round trip, so it scrapes slowly
      containers.chrony-clients-exporter = {
        image = "quay.io/superq/chrony-exporter:v0.14.0@sha256:74c7294e79dff4e6eaa48129a69a6da353a0d321f26bd315dcb682f6200c0fd1";
        autoStart = true;
        network = "host";
        exec = "--chrony.address=127.0.0.1:323 --no-collector.tracking --collector.clients --no-collector.dns-lookups --web.listen-address=:9124";
        extraConfig = {
          Container = {
            DropCapability = "ALL";
            NoNewPrivileges = true;
            ReadOnly = true;
          };
          Service.Restart = "always";
        };
      };

      # carries the udp/123 byte counters that ntp-accounting.timer writes
      containers.node-exporter = {
        image = "quay.io/prometheus/node-exporter:v1.12.1@sha256:1b4e4438faca4dd7e001dd445d161a4a2091b0fededa84093b3a8dfeae1f1be0";
        autoStart = true;
        network = "host";
        exec = "--collector.textfile.directory=/var/lib/node-exporter --no-collector.filesystem --web.listen-address=:9100";
        volumes = [ "/var/lib/ntp-accounting:/var/lib/node-exporter:ro" ];
        extraConfig = {
          Container = {
            DropCapability = "ALL";
            NoNewPrivileges = true;
            ReadOnly = true;
          };
          Service.Restart = "always";
        };
      };
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    9100
    9123
    9124
  ];
}
