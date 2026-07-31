{
  home-manager.users.navidrome = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.navidrome = {
        image = "docker.io/deluan/navidrome:0.63.2@sha256:9012939114fbb1bb641b81cf96dec5ded15f0aafefe8d47a511d7cb919658e40";
        autoStart = true;
        ports = [ "127.0.0.1:4533:4533" ];
        volumes = [
          "/var/lib/navidrome/data:/data:Z"
          "/mnt/music:/music:ro"
        ];
        environment = {
          ND_AcceptExtensions = ".mp4,.flac,.m4a";
        };
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
