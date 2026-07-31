{
  home-manager.users.lubelogger = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.lubelogger = {
        image = "ghcr.io/hargata/lubelogger:v1.7.0@sha256:01bdb486af71e641c3ae41499e0412a21f2e04fa31b25c5c6531b42c112938e5";
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
