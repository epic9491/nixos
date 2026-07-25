{ lib, ... }:
let
  cloudflareIPs = import ../cloudflare-ips.nix;
in
{
  home-manager.users.crowdsec =
    { pkgs, ... }:
    let
      acquis = pkgs.writeText "caddy.yaml" ''
        filenames:
          - /var/log/caddy/access.log
        labels:
          type: caddy
      '';

      # cloudflare serves a managed challenge, false positives stay solvable
      profiles = pkgs.writeText "profiles.yaml" ''
        name: cloudflare_captcha
        filters:
          - Alert.Remediation == true && Alert.GetScope() == "Ip"
        decisions:
          - type: captcha
            duration: 4h
        on_success: break
      '';

      whitelist = pkgs.writeText "cloudflare-whitelist.yaml" ''
        name: srv-n2/cloudflare-whitelist
        description: "Never act on Cloudflare edge addresses"
        whitelist:
          reason: "cloudflare edge"
          cidr:
        ${lib.concatMapStringsSep "\n" (r: "    - \"${r}\"") cloudflareIPs}
      '';
    in
    {
      home.stateVersion = "25.05";

      services.podman = {
        enable = true;

        networks.crowdsec = { };

        containers.crowdsec = {
          image = "docker.io/crowdsecurity/crowdsec:latest@sha256:2f527c9bb8b367120eb08b82890aa912ce96bfa1ada93dda0721700e4b4e0dde";
          autoStart = true;
          network = "crowdsec.network";
          networkAlias = [ "crowdsec" ];
          ports = [ "6060:6060" ];
          volumes = [
            "/var/lib/crowdsec/etc:/etc/crowdsec"
            "/var/lib/crowdsec/data:/var/lib/crowdsec/data"
            "/var/log/caddy:/var/log/caddy:ro"
            "${acquis}:/etc/crowdsec/acquis.d/caddy.yaml:ro"
            "${profiles}:/etc/crowdsec/profiles.yaml:ro"
            "${whitelist}:/etc/crowdsec/parsers/s02-enrich/cloudflare-whitelist.yaml:ro"
          ];
          environment = {
            COLLECTIONS = "crowdsecurity/caddy";
            DISABLE_ONLINE_API = "false";
            ENROLL_INSTANCE_NAME = "srv-n2-crowdsec";
            ENROLL_TAGS = "public caddy searxng privatebin";
          };
          environmentFile = [ "/run/secrets/crowdsec.env" ];
          extraConfig = {
            Container = {
              # carries weblogs membership into the userns to read caddy's log
              GroupAdd = "keep-groups";
              DropCapability = "ALL";
              AddCapability = [
                "CHOWN"
                "DAC_OVERRIDE"
                "FOWNER"
                "SETGID"
                "SETUID"
              ];
              NoNewPrivileges = true;
              HealthCmd = "cscli lapi status";
              HealthInterval = "30s";
              HealthTimeout = "5s";
              HealthRetries = 3;
              HealthStartPeriod = "30s";
            };
            Service.Restart = "always";
          };
        };

        containers.crowdsec-export = {
          image = "docker.io/library/python:3.14-alpine@sha256:26730869004e2b9c4b9ad09cab8625e81d256d1ce97e72df5520e806b1709f92";
          autoStart = true;
          network = "crowdsec.network";
          ports = [ "6061:6061" ];
          exec = "python3 /app/lapi-export.py";
          volumes = [
            "${../../pangolin/containers/lapi-export.py}:/app/lapi-export.py:ro"
            "/var/lib/crowdsec/etc/local_api_credentials.yaml:/etc/crowdsec/local_api_credentials.yaml:ro"
          ];
          environment = {
            LAPI_URL = "http://crowdsec:8080";
            PYTHONDONTWRITEBYTECODE = "1";
            PYTHONUNBUFFERED = "1";
          };
          extraConfig = {
            Container = {
              DropCapability = "ALL";
              NoNewPrivileges = true;
              ReadOnly = true;
              HealthCmd = "python3 -c \"import urllib.request; urllib.request.urlopen('http://127.0.0.1:6061/healthz', timeout=10)\"";
              HealthInterval = "60s";
              HealthTimeout = "15s";
              HealthRetries = 3;
              HealthStartPeriod = "30s";
            };
            Service.Restart = "always";
            Unit = {
              After = [ "podman-crowdsec.service" ];
              Wants = [ "podman-crowdsec.service" ];
            };
          };
        };

        containers.crowdsec-cloudflare = {
          image = "docker.io/crowdsecurity/cloudflare-worker-bouncer:latest@sha256:5a736b48156c0b75f900f0e6cc937b6d74b2015fe8ab240154b7059531637c9a";
          autoStart = true;
          network = "crowdsec.network";
          volumes = [
            "/run/secrets/crowdsec-cloudflare-worker.yaml:/etc/crowdsec/bouncers/crowdsec-cloudflare-worker-bouncer.yaml:ro"
          ];
          extraConfig = {
            Container = {
              DropCapability = "ALL";
              NoNewPrivileges = true;
              ReadOnly = true;
            };
            Service = {
              Restart = "always";
              # helps prevent cloudflare ratelimit
              RestartSec = 120;
            };
            Unit = {
              After = [ "podman-crowdsec.service" ];
              Wants = [ "podman-crowdsec.service" ];
              StartLimitIntervalSec = 1800;
              StartLimitBurst = 3;
            };
          };
        };
      };
    };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    6060
    6061
  ];

  sops.secrets."crowdsec.env" = {
    sopsFile = ../../../../secrets/srv-n2.crowdsec.env;
    format = "binary";
    owner = "crowdsec";
    group = "crowdsec";
    mode = "0400";
  };

  sops.secrets."crowdsec-cloudflare-worker.yaml" = {
    sopsFile = ../../../../secrets/srv-n2.crowdsec-cloudflare-worker.yaml;
    format = "binary";
    owner = "crowdsec";
    group = "crowdsec";
    mode = "0400";
  };
}
