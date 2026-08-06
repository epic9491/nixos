{
  home-manager.users.webfinger =
    { pkgs, ... }:
    let
      # no user directive, so nginx never attempts setuid with all caps dropped
      conf = pkgs.writeText "nginx.conf" ''
        worker_processes 1;
        pid /tmp/nginx.pid;
        error_log /dev/stderr warn;

        events {
          worker_connections 32;
        }

        http {
          default_type application/jrd+json;
          access_log off;
          server_tokens off;

          client_body_temp_path /tmp/client_body;
          proxy_temp_path /tmp/proxy;
          fastcgi_temp_path /tmp/fastcgi;
          uwsgi_temp_path /tmp/uwsgi;
          scgi_temp_path /tmp/scgi;

          server {
            listen 8090;
            root /srv;

            location = /.well-known/webfinger {
              try_files /webfinger.json =404;
            }

            location / { return 404; }
          }
        }
      '';
    in
    {
      home.stateVersion = "25.05";

      services.podman = {
        enable = true;

        containers.webfinger = {
          image = "docker.io/library/nginx:1.31-alpine@sha256:4a73073bd557c65b759505da037898b61f1be6cbcc3c2c3aeac22d2a470c1752";
          autoStart = true;
          # maps the host account onto nginx's uid, so the 0400 secret stays readable
          userNS = "keep-id:uid=101,gid=101";
          ports = [ "127.0.0.1:8090:8090" ];
          exec = "-g \"daemon off;\"";
          volumes = [
            "${conf}:/etc/nginx/nginx.conf:ro"
            "/run/secrets/webfinger.json:/srv/webfinger.json:ro"
          ];
          extraConfig = {
            Container = {
              # skips entrypoint, rewrites conf.d on a read-only rootfs
              Entrypoint = "nginx";
              User = "101:101";
              DropCapability = "ALL";
              NoNewPrivileges = true;
              ReadOnly = true;
              Tmpfs = "/tmp";
            };
            Service.Restart = "always";
          };
        };
      };
    };

  sops.secrets."webfinger.json" = {
    sopsFile = ../../../../secrets/srv-n2.webfinger.json;
    format = "binary";
    owner = "webfinger";
    group = "webfinger";
    mode = "0400";
  };
}
