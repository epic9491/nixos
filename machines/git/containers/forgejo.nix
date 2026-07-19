{
  home-manager.users.forgejo =
    { ... }:
    {
      home.stateVersion = "25.05";

      services.podman = {
        enable = true;

        networks.forgejo = { };

        containers.forgejo = {
          image = "codeberg.org/forgejo/forgejo:16-rootless@sha256:33a27fad6fab44e585e86ab185ba882cbf9fd6ed28b368863474a580c526f75c";
          autoStart = true;
          network = "forgejo.network";
          userNS = "keep-id:uid=1000,gid=1000";
          ports = [
            "127.0.0.1:3000:3000"
            "127.0.0.1:2222:2222"
          ];
          volumes = [
            "/var/lib/forgejo/data:/var/lib/gitea:Z"
            "/var/lib/forgejo/config:/etc/gitea:Z"
          ];
          environment = {
            FORGEJO__server__DOMAIN = "git.zorse-ruffe.ts.net";
            FORGEJO__server__ROOT_URL = "https://git.zorse-ruffe.ts.net/";
            FORGEJO__server__PROTOCOL = "http";
            FORGEJO__server__HTTP_ADDR = "0.0.0.0";
            FORGEJO__server__HTTP_PORT = "3000";

            FORGEJO__server__START_SSH_SERVER = "true";
            FORGEJO__server__SSH_LISTEN_PORT = "2222";
            FORGEJO__server__SSH_PORT = "22";
            FORGEJO__server__SSH_DOMAIN = "git.zorse-ruffe.ts.net";

            FORGEJO__database__DB_TYPE = "postgres";
            FORGEJO__database__HOST = "forgejo-db:5432";
            FORGEJO__database__NAME = "forgejo";
            FORGEJO__database__USER = "forgejo";

            FORGEJO__service__DISABLE_REGISTRATION = "true";
            FORGEJO__service__REQUIRE_SIGNIN_VIEW = "false";
            FORGEJO__service__ENABLE_NOTIFY_MAIL = "false";
            FORGEJO__service__DEFAULT_KEEP_EMAIL_PRIVATE = "true";

            FORGEJO__security__INSTALL_LOCK = "true";
            FORGEJO__session__COOKIE_SECURE = "true";
            FORGEJO__session__PROVIDER = "db";

            FORGEJO__actions__ENABLED = "true";

            FORGEJO__repository__DEFAULT_PRIVATE = "private";
            FORGEJO__repository__DEFAULT_BRANCH = "main";

            FORGEJO__log__LEVEL = "Info";
          };
          environmentFile = [ "/run/secrets/forgejo.env" ];
          extraConfig = {
            Container = {
              DropCapability = "ALL";
              NoNewPrivileges = true;
            };
            Service.Restart = "always";
            Unit = {
              After = [ "podman-forgejo-db.service" ];
              Wants = [ "podman-forgejo-db.service" ];
            };
          };
        };

        containers.forgejo-db = {
          image = "docker.io/library/postgres:17-alpine@sha256:742f40ea20b9ff2ff31db5458d127452988a2164df9e17441e191f3b72252193";
          autoStart = true;
          network = "forgejo.network";
          networkAlias = [ "forgejo-db" ];
          volumes = [ "/var/lib/forgejo/db:/var/lib/postgresql/data:Z" ];
          environment = {
            POSTGRES_DB = "forgejo";
            POSTGRES_USER = "forgejo";
            PGDATA = "/var/lib/postgresql/data/pgdata";
          };
          environmentFile = [ "/run/secrets/forgejo-db.env" ];
          extraConfig = {
            Container = {
              DropCapability = "ALL";
              AddCapability = [
                "CHOWN"
                "DAC_READ_SEARCH"
                "FOWNER"
                "SETGID"
                "SETUID"
              ];
              NoNewPrivileges = false;
            };
            Service.Restart = "always";
          };
        };
      };
    };

  sops.secrets = {
    "forgejo.env" = {
      sopsFile = ../../../secrets/git.forgejo.env;
      format = "binary";
      path = "/run/secrets/forgejo.env";
      owner = "forgejo";
      group = "forgejo";
      mode = "0400";
    };
    "forgejo-db.env" = {
      sopsFile = ../../../secrets/git.forgejo-db.env;
      format = "binary";
      path = "/run/secrets/forgejo-db.env";
      owner = "forgejo";
      group = "forgejo";
      mode = "0400";
    };
  };
}
