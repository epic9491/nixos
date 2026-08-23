
{
  home-manager.users.filebrowser = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.filebrowser = {
        image = "ghcr.io/gtsteffaniak/filebrowser:1.5.3-stable@sha256:e2ac55ccbe53d63b3f1d7d5ea5b82edf589b005a4b747b59912f97c6ba4f969e";
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
