{
  home-manager.users.owntracks =
    { pkgs, ... }:
    let
      caddyfile = pkgs.writeText "Caddyfile" ''
        {
          auto_https off
        }

        :80 {
          basic_auth {
            {$OT_AUTH_USER_1} {$OT_AUTH_HASH_1}
            {$OT_AUTH_USER_2} {$OT_AUTH_HASH_2}
          }
          handle /pub {
            reverse_proxy recorder:8083 {
              header_up X-Limit-U {http.auth.user.id}
            }
          }
          handle {
            respond 403
          }
        }
      '';
    in
    {
      home.stateVersion = "25.05";

      services.podman = {
        enable = true;

        networks.owntracks = { };

        containers.recorder = {
          image = "docker.io/owntracks/recorder:1.0.3@sha256:119b9cf15f5f45bbeab1b7f87b41948adbb9ba210900e188be21f384cdd7600a";
          autoStart = true;
          network = "owntracks.network";
          networkAlias = [ "recorder" ];
          volumes = [ "/var/lib/owntracks/recorder:/store:Z" ];
          environment = {
            # no mqtt, http auth only
            OTR_PORT = 0;
          };
          environmentFile = [ "/run/secrets/owntracks.env" ];
          extraConfig = {
            Container = {
              DropCapability = "ALL";
              NoNewPrivileges = true;
            };
            Service.Restart = "always";
          };
        };

        containers.caddy = {
          image = "docker.io/library/caddy:2.11@sha256:df7f1c2fb114453b951de51a98efc010db1655a92c2e86be6706714e2417a78d";
          autoStart = true;
          network = "owntracks.network";
          networkAlias = [ "caddy" ];
          ports = [ "127.0.0.1:8085:80" ];
          volumes = [
            "/var/lib/owntracks/caddy/data:/data:Z"
            "/var/lib/owntracks/caddy/config:/config:Z"
            "${caddyfile}:/etc/caddy/Caddyfile:ro"
          ];
          environmentFile = [ "/run/secrets/owntracks.env" ];
          extraConfig = {
            Container = {
              AddCapability = "NET_BIND_SERVICE";
              DropCapability = "ALL";
              NoNewPrivileges = true;
            };
            Service.Restart = "always";
            Unit = {
              After = [ "podman-recorder.service" ];
              Wants = [ "podman-recorder.service" ];
            };
          };
        };

      };
    };

  sops.secrets."owntracks.env" = {
    sopsFile = ../../../../secrets/srv-n1.owntracks.env;
    format = "binary";
    owner = "owntracks";
    group = "owntracks";
    mode = "0400";
  };
}
