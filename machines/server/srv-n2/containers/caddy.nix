{ lib, ... }:
let
  cloudflareIPs = import ../cloudflare-ips.nix;
  cfRanges = lib.concatStringsSep " " cloudflareIPs;

  certNames = [
    "caddy.libresearch.pem"
    "caddy.libresearch.key"
    "caddy.pasted.pem"
    "caddy.pasted.key"
    "caddy.forgd.pem"
    "caddy.forgd.key"
  ];
in
{
  home-manager.users.caddy =
    { pkgs, ... }:
    let
      caddyfile = pkgs.writeText "Caddyfile" ''
        {
          admin off
          auto_https off
          https_port 8443
          servers {
            trusted_proxies static ${cfRanges}
            client_ip_headers CF-Connecting-IP
          }
        }

        (edge) {
          @not_cloudflare not remote_ip ${cfRanges}
          abort @not_cloudflare

          log {
            output file /var/log/caddy/access.log {
              roll_size 10MiB
              roll_keep 5
              mode 640
            }
            format json
          }

          header {
            Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
            X-Content-Type-Options "nosniff"
            Referrer-Policy "no-referrer"
            Permissions-Policy "geolocation=(), microphone=(), camera=()"
            -Server
          }
        }

        libresearch.space, www.libresearch.space {
          import edge
          header X-Frame-Options "DENY"
          tls /run/secrets/caddy.libresearch.pem /run/secrets/caddy.libresearch.key
          reverse_proxy 169.254.1.2:8082 {
            header_up Host {host}
            header_up X-Real-IP {client_ip}
            header_up X-Forwarded-For {client_ip}
          }
        }

        pasted.space, www.pasted.space {
          import edge
          header X-Frame-Options "SAMEORIGIN"
          tls /run/secrets/caddy.pasted.pem /run/secrets/caddy.pasted.key
          reverse_proxy 169.254.1.2:8083 {
            header_up Host {host}
            header_up X-Real-IP {client_ip}
            header_up X-Forwarded-For {client_ip}
          }
        }

        forgd.space, www.forgd.space {
          import edge
          header X-Frame-Options "DENY"
          tls /run/secrets/caddy.forgd.pem /run/secrets/caddy.forgd.key
          request_body {
            max_size 512MB
          }
          reverse_proxy 169.254.1.2:8084 {
            header_up Host {host}
            header_up X-Real-IP {client_ip}
            header_up X-Forwarded-For {client_ip}
            flush_interval -1
          }
        }
      '';
    in
    {
      home.stateVersion = "25.05";

      services.podman = {
        enable = true;
        containers.caddy = {
          image = "docker.io/library/caddy:2-alpine@sha256:5f5c8640aae01df9654968d946d8f1a56c497f1dd5c5cda4cf95ab7c14d58648";
          autoStart = true;
          ports = [ "8443:8443" ];
          extraPodmanArgs = [ "--network=pasta:--map-host-loopback,169.254.1.2" ];
          volumes = [
            "/var/lib/caddy/data:/data"
            "/var/lib/caddy/config:/config"
            "/var/log/caddy:/var/log/caddy"
            "${caddyfile}:/etc/caddy/Caddyfile:ro"
          ]
          ++ map (n: "/run/secrets/${n}:/run/secrets/${n}:ro") certNames;
          extraConfig = {
            Container = {
              DropCapability = "ALL";
              AddCapability = [ "NET_BIND_SERVICE" ];
              NoNewPrivileges = true;
            };
            Service.Restart = "always";
          };
        };
      };
    };

  age.secrets = lib.genAttrs certNames (n: {
    file = ../../../../secrets/srv-n2.${n}.age;
    path = "/run/secrets/${n}";
    owner = "caddy";
    group = "caddy";
    mode = "0400";
  });

  networking.firewall.extraCommands = ''
    iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8443
    ${lib.concatMapStringsSep "\n" (
      r: "iptables -A nixos-fw -p tcp --dport 8443 -s ${r} -j nixos-fw-accept"
    ) cloudflareIPs}
  '';

  networking.firewall.extraStopCommands = ''
    iptables -t nat -D PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8443 || true
    ${lib.concatMapStringsSep "\n" (
      r: "iptables -D nixos-fw -p tcp --dport 8443 -s ${r} -j nixos-fw-accept || true"
    ) cloudflareIPs}
  '';
}
