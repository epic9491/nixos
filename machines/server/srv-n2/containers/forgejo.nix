{ lib, ... }:
let
  sshPort = 2222;
  sshAdvertisedPort = 420;
in
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
          ports = [
            "127.0.0.1:8084:3000"
            "${toString sshPort}:${toString sshPort}"
          ];
          volumes = [
            "/var/lib/forgejo/data:/var/lib/gitea"
            "/var/lib/forgejo/config:/etc/gitea"
            "/var/log/forgejo:/var/log/forgejo"
          ];
          environment = {
            FORGEJO__server__DOMAIN = "forgd.space";
            FORGEJO__server__ROOT_URL = "https://forgd.space/";
            FORGEJO__server__PROTOCOL = "http";
            FORGEJO__server__HTTP_ADDR = "0.0.0.0";
            FORGEJO__server__HTTP_PORT = "3000";

            FORGEJO__server__START_SSH_SERVER = "true";
            FORGEJO__server__SSH_LISTEN_PORT = toString sshPort;
            FORGEJO__server__SSH_PORT = toString sshAdvertisedPort;
            FORGEJO__server__SSH_DOMAIN = "forgd.space";

            FORGEJO__database__DB_TYPE = "postgres";
            FORGEJO__database__HOST = "forgejo-db:5432";
            FORGEJO__database__NAME = "forgejo";
            FORGEJO__database__USER = "forgejo";

            FORGEJO__service__DISABLE_REGISTRATION = "true";
            FORGEJO__service__ALLOW_ONLY_EXTERNAL_REGISTRATION = "false";
            FORGEJO__service__REGISTER_EMAIL_CONFIRM = "true";
            FORGEJO__service__ENABLE_NOTIFY_MAIL = "false";
            FORGEJO__service__DEFAULT_KEEP_EMAIL_PRIVATE = "true";
            FORGEJO__service__DEFAULT_ALLOW_CREATE_ORGANIZATION = "false";
            FORGEJO__service__NO_REPLY_ADDRESS = "noreply.forgd.space";

            FORGEJO__security__INSTALL_LOCK = "true";
            FORGEJO__security__LOGIN_REMEMBER_DAYS = "7";
            FORGEJO__session__COOKIE_SECURE = "true";
            FORGEJO__session__PROVIDER = "db";

            FORGEJO__actions__ENABLED = "true";

            FORGEJO__repository__DEFAULT_PRIVATE = "private";
            FORGEJO__repository__DISABLE_HTTP_GIT = "false";
            FORGEJO__repository__DEFAULT_BRANCH = "main";

            FORGEJO__openid__ENABLE_OPENID_SIGNIN = "false";
            FORGEJO__openid__ENABLE_OPENID_SIGNUP = "false";
            FORGEJO__other__SHOW_FOOTER_VERSION = "false";

            FORGEJO__log__MODE = "console,file";
            FORGEJO__log__LEVEL = "Info";
            FORGEJO__log__ROOT_PATH = "/var/log/forgejo";
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
          volumes = [ "/var/lib/forgejo/db:/var/lib/postgresql/data" ];
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

  age.secrets = {
    "forgejo.env" = {
      file = ../../../../secrets/srv-n2.forgejo.env.age;
      path = "/run/secrets/forgejo.env";
      owner = "forgejo";
      group = "forgejo";
      mode = "0400";
    };
    "forgejo-db.env" = {
      file = ../../../../secrets/srv-n2.forgejo-db.env.age;
      path = "/run/secrets/forgejo-db.env";
      owner = "forgejo";
      group = "forgejo";
      mode = "0400";
    };
  };

  networking.firewall.extraCommands = lib.mkAfter ''
    iptables -t nat -A PREROUTING -p tcp --dport ${toString sshAdvertisedPort} -j REDIRECT --to-port ${toString sshPort}
    iptables -A nixos-fw -p tcp --dport ${toString sshPort} -j nixos-fw-accept
  '';

  networking.firewall.extraStopCommands = lib.mkAfter ''
    iptables -t nat -D PREROUTING -p tcp --dport ${toString sshAdvertisedPort} -j REDIRECT --to-port ${toString sshPort} || true
    iptables -D nixos-fw -p tcp --dport ${toString sshPort} -j nixos-fw-accept || true
  '';
}
