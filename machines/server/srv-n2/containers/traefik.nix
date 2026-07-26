{
  home-manager.users.traefik =
    { pkgs, ... }:
    let
      # yaegi interprets this from disk, so the official image stays unmodified
      bouncer = pkgs.fetchFromGitHub {
        owner = "maxlerebourg";
        repo = "crowdsec-bouncer-traefik-plugin";
        tag = "v1.6.0";
        hash = "sha256-Wf2R2vgwBzUxuk96njtGFu8w7mdP5bm+5ZuO3D1+AbA=";
      };

      static = pkgs.writeText "traefik.yml" ''
        global:
          checkNewVersion: false
          sendAnonymousUsage: false

        entryPoints:
          web:
            address: ":80"
            http:
              redirections:
                entryPoint:
                  to: websecure
                  scheme: https
          websecure:
            address: ":443"
            http:
              tls:
                certResolver: le
            http3: {}

        certificatesResolvers:
          le:
            acme:
              email: acme@gaialabs.space
              storage: /acme/acme.json
              tlsChallenge: {}

        providers:
          file:
            directory: /etc/traefik/dynamic
            watch: true

        experimental:
          localPlugins:
            bouncer:
              moduleName: github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin

        accessLog:
          filePath: /var/log/traefik/access.log
          format: json
          fields:
            queryParameters:
              defaultMode: drop

        log:
          level: ERROR

        api:
          dashboard: false
      '';

      csp = "upgrade-insecure-requests; default-src 'none'; script-src 'self'; style-src 'self' 'unsafe-inline'; form-action 'self' https:; font-src 'self'; frame-ancestors 'self'; base-uri 'self'; connect-src 'self'; img-src * data:; frame-src https:;";

      dynamic = pkgs.writeTextDir "routers.yml" ''
        http:
          middlewares:
            hardening:
              headers:
                stsSeconds: 31536000
                stsIncludeSubdomains: true
                stsPreload: true
                contentTypeNosniff: true
                referrerPolicy: no-referrer
                permissionsPolicy: "geolocation=(), microphone=(), camera=()"
                customResponseHeaders:
                  Cross-Origin-Opener-Policy: same-origin
                  Server: ""

            libresearch-headers:
              headers:
                frameDeny: true
                contentSecurityPolicy: "${csp}"

            pasted-headers:
              headers:
                customFrameOptionsValue: SAMEORIGIN

          routers:
            libresearch:
              rule: "Host(`libresearch.space`) || Host(`www.libresearch.space`)"
              entryPoints: [ websecure ]
              middlewares: [ crowdsec, hardening, libresearch-headers ]
              service: libresearch
            pasted:
              rule: "Host(`pasted.space`) || Host(`www.pasted.space`)"
              entryPoints: [ websecure ]
              middlewares: [ crowdsec, hardening, pasted-headers ]
              service: pasted

          services:
            libresearch:
              loadBalancer:
                servers:
                  - url: "http://169.254.1.2:8084"
            pasted:
              loadBalancer:
                servers:
                  - url: "http://169.254.1.2:8085"

        tls:
          options:
            default:
              minVersion: VersionTLS12
              curvePreferences: [ X25519, CurveP256 ]
              cipherSuites:
                - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
                - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
                - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305
                - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
                - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
                - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305
      '';
    in
    {
      home.stateVersion = "25.05";

      services.podman = {
        enable = true;

        containers.traefik = {
          image = "docker.io/library/traefik:v3.7@sha256:652929a140a32d7cafafb13c6cdfab5376cfeff800f51397b87b524501ed02a8";
          autoStart = true;
          ports = [
            "80:80"
            "443:443"
            "443:443/udp"
          ];
          extraPodmanArgs = [ "--network=pasta:--map-host-loopback,169.254.1.2" ];
          volumes = [
            "${static}:/etc/traefik/traefik.yml:ro"
            "${dynamic}/routers.yml:/etc/traefik/dynamic/routers.yml:ro"
            "/run/secrets/traefik-crowdsec.yml:/etc/traefik/dynamic/crowdsec.yml:ro"
            "${bouncer}:/plugins-local/src/github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin:ro"
            "/var/lib/traefik/acme:/acme"
            "/var/log/traefik:/var/log/traefik"
          ];
          extraConfig = {
            Container = {
              DropCapability = "ALL";
              AddCapability = [ "NET_BIND_SERVICE" ];
              NoNewPrivileges = true;
              ReadOnly = true;
              Tmpfs = "/tmp";
            };
            Service.Restart = "always";
          };
        };
      };
    };

  # rootless podman cannot publish 80/443 otherwise
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

  services.logrotate.settings."/var/log/traefik/access.log" = {
    size = "50M";
    rotate = 5;
    copytruncate = true;
    missingok = true;
    notifempty = true;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  sops.secrets."traefik-crowdsec.yml" = {
    sopsFile = ../../../../secrets/srv-n2.traefik-crowdsec.yml;
    format = "binary";
    owner = "traefik";
    group = "traefik";
    mode = "0400";
  };
}
