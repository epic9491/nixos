{ lib, ... }:
{
  users.groups.render.gid = lib.mkForce 105;
  users.users.jellyfin.extraGroups = [ "render" ];

  home-manager.users.jellyfin = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.jellyfin = {
        image = "docker.io/jellyfin/jellyfin:12.0@sha256:baba630419915985442f315f08b0cf46d9f4c8a0cc4bd38e94a6d35751dd5ef5";
        autoStart = true;
        ports = [ "8096:8096" ];
        volumes = [
          "/var/lib/jellyfin/config:/config:Z"
          "/var/lib/jellyfin/cache:/cache:Z"
          "/srv/media:/media:ro"
        ];
        devices = [ "/dev/dri/renderD128" ];
        extraPodmanArgs = [ "--group-add=keep-groups" ];
        extraConfig.Container.NoNewPrivileges = true;
        extraConfig.Service = {
          Restart = "on-failure";
          TimeoutStartSec = 900;
        };
      };
    };
  };
}
