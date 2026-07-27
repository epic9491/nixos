{
  users.manageLingering = true;

  # pinned, the host-side idmap chown on mediapool/p2p depends on it
  users.users.gumbo = {
    uid = 1000;
    linger = true;
  };

  home-manager.users.gumbo = { ... }: {
    services.podman = {
      enable = true;
      containers.qbittorrent = {
        image = "lscr.io/linuxserver/qbittorrent:latest@sha256:352371a7242e8b4aa10958ca02076d1023758070519b89a10251475fb9f1a35a";
        autoStart = true;
        network = "host";
        userNS = "keep-id";
        volumes = [
          "/var/lib/qbittorrent/config:/config:Z"
          "/srv/p2p/downloads:/downloads"
          "/srv/p2p/seeds:/seeds"
        ];
        environment = {
          PUID = 1000;
          PGID = 100;
          TZ = "America/Chicago";
          WEBUI_PORT = 8080;
        };
        extraConfig.Container = {
          DropCapability = "ALL";
          NoNewPrivileges = true;
          # s6 preinit aborts unless /run is owned by the keep-id uid
          Tmpfs = "/run:uid=1000,gid=100,mode=0755";
        };
        extraConfig.Service.Restart = "always";
      };
    };
  };
}
