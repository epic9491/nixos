{
  users.manageLingering = true;

  users.users.qbittorrent = {
    isSystemUser = true;
    group = "qbittorrent";
    linger = true;
    home = "/var/lib/qbittorrent";
    createHome = true;
    autoSubUidGidRange = true;
  };
  users.groups.qbittorrent = { };

  home-manager.users.qbittorrent = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.qbittorrent = {
        image = "lscr.io/linuxserver/qbittorrent:latest";
        autoStart = true;
        autoUpdate = "registry";
        network = "host";
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
