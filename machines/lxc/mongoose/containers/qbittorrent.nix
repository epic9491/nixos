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
        image = "lscr.io/linuxserver/qbittorrent:latest@sha256:6816d2b144b1eb97665f886e41e18a14d026ba78c9d0953fc68a1211ea819433";
        autoStart = true;
        network = "host";
        userNS = "keep-id";
        volumes = [
          "/var/lib/qbittorrent/config:/config:Z"
          "/srv/p2p/downloads:/downloads"
          "/srv/p2p/seeds:/seeds"
        ];
        environment = {
          TZ = "America/Chicago";
          WEBUI_PORT = 8080;
        };
        extraConfig.Container = {
          DropCapability = "ALL";
          NoNewPrivileges = true;
          # s6 preinit needs /run owned by the keep-id uid, only --mount can chown it
          Mount = "type=tmpfs,destination=/run,chown=true";
        };
        extraConfig.Service.Restart = "always";
      };
    };
  };
}
