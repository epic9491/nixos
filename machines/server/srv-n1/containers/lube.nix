{
  home-manager.users.lubelogger = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.lubelogger = {
        image = "ghcr.io/hargata/lubelogger:v1.7.3@sha256:c9d2bbb48c7f84d90e54496e2cd60422e56a5f2345c8a539ebe09f77e629d321";
        autoStart = true;
        ports = [ "127.0.0.1:8081:8080" ];
        volumes = [
          "/var/lib/lubelogger/data:/App/data:Z"
          "/var/lib/lubelogger/keys:/root/.aspnet/DataProtection-Keys:Z"
        ];
        extraConfig = {
          Container = {
            DropCapability = "ALL";
            NoNewPrivileges = true;
          };
          Service.Restart = "always";
        };
      };
    };
  };
}
