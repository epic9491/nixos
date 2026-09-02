{
  home-manager.users.lubelogger = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.lubelogger = {
        image = "ghcr.io/hargata/lubelogger:v1.7.2@sha256:8d662c13237dd83fac33def4071076fe906108589f85b1368f652c16f5f2dda7";
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
