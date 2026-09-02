{
  home-manager.users.kavita = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.kavita = {
        image = "docker.io/jvmilazz0/kavita:0.9.1@sha256:31181a32f0dda73cae68721867028a7253d57881b58bea5754cd9e578e75421a";
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
