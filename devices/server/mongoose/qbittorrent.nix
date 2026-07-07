{
  users.manageLingering = true;
  users.users.gumbo.linger = true;

  systemd.tmpfiles.rules = [
    "Z /var/lib/qbittorrent 0755 gumbo users -"
    "Z /mnt/data/downloads 0755 gumbo users -"
    "Z /mnt/data/seeds 0755 gumbo users -"
  ];

  home-manager.users.gumbo = { ... }: {
    services.podman = {
      enable = true;
      containers.qbittorrent = {
        image = "lscr.io/linuxserver/qbittorrent:latest";
        autoStart = true;
        autoUpdate = "registry";
        network = "host";
        userNS = "keep-id";
        volumes = [
          "/var/lib/qbittorrent/config:/config:Z"
          "/mnt/data/downloads:/downloads:Z"
          "/mnt/data/seeds:/seeds:Z"
        ];
        environment = {
          PUID = 1000;
          PGID = 1000;
          TZ = "America/Chicago";
          WEBUI_PORT = 8080;
        };
        extraConfig.Service.Restart = "always";
      };
    };
  };
}
