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
          volumes = [
            "/var/lib/crowdsec/etc:/etc/crowdsec"
            "/var/lib/crowdsec/data:/var/lib/crowdsec/data"
            "/var/log/caddy:/var/log/caddy:ro"
            "${acquis}:/etc/crowdsec/acquis.d/caddy.yaml:ro"
            "${profiles}:/etc/crowdsec/profiles.yaml:ro"
            "${whitelist}:/etc/crowdsec/parsers/s02-enrich/cloudflare-whitelist.yaml:ro"
          ];
          environment = {
            COLLECTIONS = "crowdsecurity/caddy crowdsecurity/appsec-virtual-patching crowdsecurity/appsec-generic-rules";
            DISABLE_ONLINE_API = "false";
          };
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

        containers.crowdsec-cloudflare = {
          image = "docker.io/crowdsecurity/cloudflare-bouncer:latest@sha256:39719a070c154866ebc81335e70fdfa1c61eac45025fee7d9bbf8da689fbb2c6";
          autoStart = true;
          network = "crowdsec.network";
          volumes = [
            "/run/secrets/crowdsec-cloudflare.yaml:/etc/crowdsec/bouncers/crowdsec-cloudflare-bouncer.yaml:ro"
          ];
          extraConfig = {
            Container = {
              DropCapability = "ALL";
              NoNewPrivileges = true;
              ReadOnly = true;
            };
            Service.Restart = "always";
            Unit = {
              After = [ "podman-crowdsec.service" ];
              Wants = [ "podman-crowdsec.service" ];
            };
          };
        };
      };
    };

  age.secrets."crowdsec-cloudflare.yaml" = {
    file = ../../../../secrets/srv-n2.crowdsec-cloudflare.yaml.age;
    path = "/run/secrets/crowdsec-cloudflare.yaml";
    owner = "crowdsec";
    group = "crowdsec";
    mode = "0400";
  };
}
