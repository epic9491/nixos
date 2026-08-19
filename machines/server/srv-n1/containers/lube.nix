{
  home-manager.users.lubelogger = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.lubelogger = {
        image = "ghcr.io/hargata/lubelogger:v1.7.1@sha256:678a5c4af387e525f06ef954b454efe536745f517f2078dc646ccce9332adb9d";
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
