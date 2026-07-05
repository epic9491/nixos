{
  home-manager.users.caddy =
    { pkgs, ... }:
    let
      caddyfile = pkgs.writeText "Caddyfile" ''
        {
          default_bind 100.69.69.210
          http_port 8080
          https_port 8443
        }

        {env.DOMAIN} {
          reverse_proxy 100.69.69.210:4533
          tls {
            dns cloudflare {env.CF_API_TOKEN}
          }
        }

        {env.COCKPIT_DOMAIN} {
          reverse_proxy 127.0.0.1:9090
          tls {
            dns cloudflare {env.CF_API_TOKEN}
          }
        }
      '';
    in
    {
      home.stateVersion = "25.05";

      services.podman = {
        enable = true;
        containers.caddy = {
          image = "ghcr.io/caddybuilds/caddy-cloudflare:latest";
          autoStart = true;
          autoUpdate = "registry";
          network = "host";
          volumes = [
            "/var/lib/caddy/data:/data:Z"
            "/var/lib/caddy/config:/config:Z"
            "${caddyfile}:/etc/caddy/Caddyfile:ro"
          ];
          environmentFile = [ "/run/secrets/caddy.env" ];
          extraConfig.Service.Restart = "always";
        };
      };
    };

  age.secrets."caddy.env" = {
    file = ../../../../../secrets/srv-n1.caddy.env.age;
    path = "/run/secrets/caddy.env";
    owner = "caddy";
    group = "caddy";
    mode = "0400";
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 8443 ];

  networking.firewall.extraCommands = ''
    iptables -t nat -A PREROUTING -d 100.69.69.210 -p tcp --dport 443 -j REDIRECT --to-port 8443
  '';
  networking.firewall.extraStopCommands = ''
    iptables -t nat -D PREROUTING -d 100.69.69.210 -p tcp --dport 443 -j REDIRECT --to-port 8443 || true
  '';
}
