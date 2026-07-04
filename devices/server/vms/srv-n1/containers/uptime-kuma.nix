{
  home-manager.users."uptime-kuma" = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.uptime-kuma = {
        image = "docker.io/louislam/uptime-kuma:latest";
        autoStart = true;
        autoUpdate = "registry";
        ports = [ "127.0.0.1:3001:3001" ];
        volumes = [ "/var/lib/uptime-kuma/data:/app/data:Z" ];
        extraConfig.Service.Restart = "always";
      };
    };
  };
}
