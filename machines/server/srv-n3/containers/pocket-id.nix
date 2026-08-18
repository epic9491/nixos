{
  home-manager.users.pocket-id =
    { ... }:
    {
      home.stateVersion = "25.05";

      services.podman = {
        enable = true;

        containers.pocket-id = {
          image = "ghcr.io/pocket-id/pocket-id:v2-distroless@sha256:e0f83a42a78d0759b6d2d8c7380ef0fa8a4c95dfa01ad88740a073ae9cc4ba94";
          autoStart = true;
          userNS = "keep-id:uid=65532,gid=65532";
          ports = [ "127.0.0.1:1411:1411" ];
          volumes = [
            "/var/lib/pocket-id/data:/app/data:Z"
            "/run/secrets/pocket-id.key:/run/secrets/encryption-key:ro"
          ];
          environment = {
            ENCRYPTION_KEY_FILE = "/run/secrets/encryption-key";
            ALLOW_INSECURE_CALLBACK_URLS = "false";
            ANALYTICS_DISABLED = "true";
            VERSION_CHECK_DISABLED = "true";
            LOG_JSON = "true";
          };
          environmentFile = [ "/run/secrets/pocket-id.env" ];
          extraPodmanArgs = [ "--network=pasta" ];
          extraConfig = {
            Container = {
              DropCapability = "ALL";
              NoNewPrivileges = true;
              ReadOnly = true;
              Tmpfs = "/tmp";
              # distroless has no shell, so the exec form is mandatory here
              HealthCmd = ''["/app/pocket-id", "healthcheck"]'';
              HealthInterval = "1m30s";
              HealthTimeout = "5s";
              HealthRetries = 3;
              HealthStartPeriod = "10s";
            };
            Service.Restart = "always";
          };
        };
      };
    };

  sops.secrets = {
    "pocket-id.env" = {
      sopsFile = ../../../../secrets/srv-n3.pocket-id.env;
      format = "binary";
      path = "/run/secrets/pocket-id.env";
      owner = "pocket-id";
      group = "pocket-id";
      mode = "0400";
    };
    "pocket-id.key" = {
      sopsFile = ../../../../secrets/srv-n3.pocket-id.key;
      format = "binary";
      path = "/run/secrets/pocket-id.key";
      owner = "pocket-id";
      group = "pocket-id";
      mode = "0400";
    };
  };
}
