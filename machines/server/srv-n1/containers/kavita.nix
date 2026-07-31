{
  home-manager.users.kavita = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.kavita = {
        image = "docker.io/jvmilazz0/kavita:0.9.0.2@sha256:ca6af7a18d7124d014702983c2364e485294f808c1552e9555f2595b7cda7982";
        autoStart = true;
        ports = [ "127.0.0.1:5000:5000" ];
        volumes = [
          "/var/lib/kavita/config:/kavita/config:Z"
          "/mnt/manga:/library:ro"
        ];
        environment = {
          TZ = "Etc/UTC";
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
