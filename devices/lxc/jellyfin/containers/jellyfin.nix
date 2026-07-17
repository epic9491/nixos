{ lib, ... }:
{
  users.groups.render.gid = lib.mkForce 105;
  users.users.jellyfin.extraGroups = [ "render" ];

  home-manager.users.jellyfin = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.jellyfin = {
        image = "docker.io/jellyfin/jellyfin:latest@sha256:aefb67e6a7ff1debdd154a78a7bbb780fd0c873d8639210a7f6a2016ad2b35db";
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
