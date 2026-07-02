{
  home-manager.users.kavita = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.kavita = {
        image = "docker.io/jvmilazz0/kavita:latest";
        autoStart = true;
        autoUpdate = "registry";
        ports = [ "127.0.0.1:5000:5000" ];
        volumes = [
          "/srv/kavita/config:/kavita/config:Z"
          "/mnt/manga:/library:ro"
        ];
        environment = {
          TZ = "Etc/UTC";
        };
        extraConfig.Service.Restart = "always";
      };
    };
  };
}
