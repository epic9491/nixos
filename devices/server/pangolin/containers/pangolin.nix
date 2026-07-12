{
  home-manager.users.pangolin = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;

      settings.containers.containers.base_hosts_file = "none";

      networks.pangolin = { };

      containers.pangolin = {
        image = "docker.io/fosrl/pangolin@sha256:a48fa977d95b44a0e7fda5b94e8f6a60c0aece3ff6063b23d7bf2d814baa279c";
        autoStart = true;
        autoUpdate = "registry";
        network = "pangolin.network";
        volumes = [ "/var/lib/pangolin/config:/app/config" ];
        extraConfig = {
          Container = {
            HealthCmd = "curl -f http://localhost:3001/api/v1/";
            HealthInterval = "10s";
            HealthTimeout = "10s";
            HealthRetries = 15;
            Notify = "healthy";
          };
          Service.Restart = "always";
        };
      };

      containers.gerbil = {
        image = "docker.io/fosrl/gerbil@sha256:431aaed724dab25e7b7b5519abd756a37401956cd4d1f9b696fedbb16f9e4ae6";
        autoStart = true;
        autoUpdate = "registry";
        network = "pangolin.network";
        exec = "--reachableAt=http://gerbil:3004 --generateAndSaveKeyTo=/var/config/key --remoteConfig=http://pangolin:3001/api/v1/";
        ports = [
          "51820:51820/udp"
          "21820:21820/udp"
          "8443:443"
          "8080:80"
        ];
        volumes = [ "/var/lib/pangolin/config:/var/config" ];
        devices = [ "/dev/net/tun" ];
        extraPodmanArgs = [ "--cap-add=NET_ADMIN" ];
        extraConfig = {
          Service.Restart = "always";
          Unit = {
            After = [ "podman-pangolin.service" ];
            Wants = [ "podman-pangolin.service" ];
          };
        };
      };

      containers.traefik = {
        image = "docker.io/library/traefik@sha256:1cb3845d7a05e1473c9086351426597e911db49db382b6e4769f9b0744962ac8";
        autoStart = true;
        autoUpdate = "registry";
        network = "container:gerbil";
        exec = "--configFile=/etc/traefik/traefik_config.yml";
        volumes = [
          "/var/lib/pangolin/config/traefik:/etc/traefik:ro"
          "/var/lib/pangolin/config/letsencrypt:/letsencrypt"
          "/var/lib/pangolin/config/traefik/logs:/var/log/traefik"
          "/var/lib/pangolin/config/traefik/rules:/rules"
        ];
        extraConfig = {
          Service.Restart = "always";
          Unit = {
            After = [
              "podman-pangolin.service"
              "podman-gerbil.service"
            ];
            Wants = [
              "podman-pangolin.service"
              "podman-gerbil.service"
            ];
          };
        };
      };

      containers.crowdsec = {
        image = "docker.io/crowdsecurity/crowdsec@sha256:2f527c9bb8b367120eb08b82890aa912ce96bfa1ada93dda0721700e4b4e0dde";
        autoStart = true;
        autoUpdate = "registry";
        network = "pangolin.network";
        ports = [ "6060:6060" ];
        volumes = [
          "/var/lib/pangolin/config/crowdsec:/etc/crowdsec"
          "/var/lib/pangolin/config/crowdsec/db:/var/lib/crowdsec/data"
          "/var/lib/pangolin/config/traefik/logs:/var/log/traefik"
        ];
        environment = {
          GID = "1000";
          COLLECTIONS = "crowdsecurity/traefik crowdsecurity/appsec-virtual-patching crowdsecurity/appsec-generic-rules crowdsecurity/linux";
          PARSERS = "crowdsecurity/whitelists";
          ENROLL_INSTANCE_NAME = "pangolin-crowdsec";
          ENROLL_TAGS = "docker";
        };
        environmentFile = [ "/run/secrets/pangolin.crowdsec.env" ];
        extraConfig = {
          Container = {
            HealthCmd = "cscli lapi status";
            HealthInterval = "10s";
            HealthTimeout = "5s";
            HealthRetries = 3;
            HealthStartPeriod = "30s";
          };
          Service.Restart = "always";
        };
      };

      containers.middleware-manager = {
        image = "docker.io/hhftechnology/middleware-manager@sha256:d739d47886631a04bd7e3c83d2c02799010d0a944c2f6256bfcd9b89f0b25487";
        autoStart = false;
        autoUpdate = "registry";
        network = "pangolin.network";
        ports = [ "3456:3456" ];
        volumes = [
          "/var/lib/pangolin/data:/data"
          "/var/lib/pangolin/config/traefik/rules:/conf"
        ];
        environment = {
          PANGOLIN_API_URL = "http://pangolin:3001/api/v1";
          TRAEFIK_CONF_DIR = "/conf";
          DB_PATH = "/data/middleware.db";
          PORT = "3456";
        };
        extraConfig = {
          Service.Restart = "always";
          Unit = {
            After = [ "podman-pangolin.service" ];
            Wants = [ "podman-pangolin.service" ];
          };
        };
      };
    };

    systemd.user.services.crowdsec-restart = {
      Unit.Description = "Restart crowdsec container";
      Service = {
        Type = "oneshot";
        ExecStart = "/run/current-system/sw/bin/systemctl --user restart podman-crowdsec.service";
      };
    };

    systemd.user.timers.crowdsec-restart = {
      Unit.Description = "Nightly crowdsec container restart at 4am Eastern";
      Timer = {
        OnCalendar = "*-*-* 04:00:00 America/New_York";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };

  age.secrets."pangolin.crowdsec.env" = {
    file = ../../../../secrets/pangolin.crowdsec.env.age;
    path = "/run/secrets/pangolin.crowdsec.env";
    owner = "pangolin";
    group = "pangolin";
    mode = "0400";
  };

  networking.firewall.allowedTCPPorts = [
    8080
    8443
  ];
  networking.firewall.allowedUDPPorts = [
    51820
    21820
  ];
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    3456
    6060
  ];

  networking.firewall.extraCommands = ''
    iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
    iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8443
    ip6tables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
    ip6tables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8443
  '';
  networking.firewall.extraStopCommands = ''
    iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080 || true
    iptables -t nat -D PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8443 || true
    ip6tables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080 || true
    ip6tables -t nat -D PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8443 || true
  '';
}
