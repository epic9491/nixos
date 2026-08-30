
{
  home-manager.users.filebrowser = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.filebrowser = {
        image = "ghcr.io/gtsteffaniak/filebrowser:1.5.5-stable@sha256:ffc2c9914b37f6e9afc67e8cf5693f5fa63bb0a83491dc9229caa073828d7503";
        autoStart = true;
        ports = [ "127.0.0.1:8090:8080" ];
        userNS = "keep-id:uid=1000,gid=1000";
        volumes = [ "/var/lib/filebrowser/data:/home/filebrowser/data" ];
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
