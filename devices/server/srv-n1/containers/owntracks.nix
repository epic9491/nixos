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
          image = "docker.io/owntracks/recorder@sha256:050c3ac9ed798d4110f12e53851e94f9fa0fcecb16cf4d7457967eac2e498da7";
          autoStart = true;
          autoUpdate = "registry";
          network = "owntracks.network";
          networkAlias = [ "recorder" ];
          volumes = [ "/var/lib/owntracks/recorder:/store:Z" ];
          environment = {
            # no mqtt, http auth only
            OTR_PORT = 0;
          };
          environmentFile = [ "/run/secrets/owntracks.env" ];
          extraConfig.Service.Restart = "always";
        };

        containers.caddy = {
          image = "docker.io/library/caddy@sha256:af5fdcd76f2db5e4e974ee92f96ee8c0fc3edb55bd4ba5032547cbf3f65e486d";
          autoStart = true;
          autoUpdate = "registry";
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
            Service.Restart = "always";
            Unit = {
              After = [ "podman-recorder.service" ];
              Wants = [ "podman-recorder.service" ];
            };
          };
        };

      };
    };

  age.secrets."owntracks.env" = {
    file = ../../../../secrets/srv-n1.owntracks.env.age;
    path = "/run/secrets/owntracks.env";
    owner = "owntracks";
    group = "owntracks";
    mode = "0400";
  };
}
