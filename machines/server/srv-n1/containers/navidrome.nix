{
  home-manager.users.navidrome = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.navidrome = {
        image = "docker.io/deluan/navidrome:0.64.0@sha256:a384948b81bd1529986c5960169e7fc4fa00f46bde6bd517971a4c36671db2af";
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
