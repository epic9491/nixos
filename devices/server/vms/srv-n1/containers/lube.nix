{
  home-manager.users.lubelogger = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.lubelogger = {
        image = "ghcr.io/hargata/lubelogger:latest";
        autoStart = true;
        autoUpdate = "registry";
        ports = [ "127.0.0.1:8081:8080" ];
        volumes = [ "/var/lib/lubelogger/data:/app/data:Z" ];
        volumes = [ "/var/lib/lubelogger/keys:/root/.aspnet/DataProtection-Keys:Z" ];
        extraConfig.Service.Restart = "always";
      };
    };
  };
}
