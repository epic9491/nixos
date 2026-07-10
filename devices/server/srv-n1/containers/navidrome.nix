{
  home-manager.users.navidrome = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.navidrome = {
        image = "docker.io/deluan/navidrome:latest";
        autoStart = true;
        autoUpdate = "registry";
        ports = [ "127.0.0.1:4533:4533" ];
        volumes = [
          "/var/lib/navidrome/data:/data:Z"
          "/mnt/music:/music:ro"
        ];
        environment = {
          ND_AcceptExtensions = ".mp4,.flac,.m4a";
        };
        extraConfig.Service.Restart = "always";
      };
    };
  };
}
