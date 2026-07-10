{ config, ... }:
{
  age.secrets."tuwunel-token" = {
    file = ../../../secrets/tuwunel-token.age;
    path = "/run/agenix/tuwunel-token";
    owner = "root";
    group = "root";
    mode = "0444";
  };

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;
  boot.kernel.sysctl."net.ipv6.ip_unprivileged_port_start" = 80;

  containers.tuwunel = {
    autoStart = true;
    bindMounts."/run/secrets/tuwunel-token" = {
      hostPath = "/run/agenix/tuwunel-token";
      isReadOnly = true;
    };
    config = { config, ... }: {
      system.stateVersion = "25.11";
      users.users.matrix-tuwunel = {
        isSystemUser = true;
        group = "matrix-tuwunel";
      };
      users.groups.matrix-tuwunel = {};
      services.matrix-tuwunel = {
        enable = true;
        user = "matrix-tuwunel";
        group = "matrix-tuwunel";
        settings.global = {
          server_name = "gaialabs.me";
          allow_registration = true;
          registration_token_file = "/run/secrets/tuwunel-token";
          address = [ "0.0.0.0" "::0" ];
        };
      };
    };
  };

  containers.nginx = {
    autoStart = true;
    config = { config, pkgs, ... }: {
      system.stateVersion = "25.11";
      services.nginx = {
        enable = true;
        virtualHosts."gaialabs.me" = {
          listen = [
            { addr = "127.0.0.1"; port = 8081; }
          ];
          locations."= /.well-known/matrix/server" = {
            extraConfig = ''
              default_type application/json;
              add_header Access-Control-Allow-Origin *;
              return 200 '{"m.server": "matrix.gaialabs.me:443"}';
            '';
          };
          locations."= /.well-known/matrix/client" = {
            extraConfig = ''
              default_type application/json;
              add_header Access-Control-Allow-Origin *;
              return 200 '{"m.homeserver": {"base_url": "https://matrix.gaialabs.me"}}';
            '';
          };
        };
      };
    };
  };

  services.traefik = {
    enable = true;
    group = "traefik";
    staticConfigOptions = {
      log.level = "DEBUG";
      entryPoints = {
        web.address = ":80";
        websecure.address = ":443";
      };
      certificatesResolvers.letls.acme = {
        email = "an-email@email.com";
        storage = "/var/lib/traefik/acme.json";
        httpChallenge.entryPoint = "web";
      };
    };
    dynamicConfigOptions.http = {
      services.tuwunel.loadBalancer.servers = [
        { url = "http://localhost:6167"; }
      ];
      services.wellknown.loadBalancer.servers = [
        { url = "http://localhost:8081"; }
      ];
      routers.tuwunel = {
        rule = "Host(`matrix.gaialabs.me`)";
        tls.certResolver = "letls";
        service = "tuwunel";
        entrypoints = "websecure";
      };
      routers.wellknown = {
        rule = "Host(`gaialabs.me`)";
        tls.certResolver = "letls";
        service = "wellknown";
        entrypoints = "websecure";
      };
    };
  };
}
