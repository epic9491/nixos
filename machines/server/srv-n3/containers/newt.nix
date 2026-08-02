{
  home-manager.users.newt =
    { ... }:
    {
      home.stateVersion = "25.05";

      services.podman = {
        enable = true;

        containers.newt = {
          image = "docker.io/fosrl/newt:1.15@sha256:d69d047c816ca7721eae90d5f3cd3be53b615b3d498678be21488d666538ee5c";
          autoStart = true;
          environmentFile = [ "/run/secrets/newt.env" ];
          devices = [ "/dev/net/tun" ];
          extraPodmanArgs = [ "--network=pasta:--map-host-loopback,169.254.1.2" ];
          extraConfig = {
            Container = {
              AddCapability = "NET_ADMIN";
              DropCapability = "ALL";
              NoNewPrivileges = true;
            };
            Service.RestartSec = 2;
          };
        };
      };
    };

  sops.secrets."newt.env" = {
    sopsFile = ../../../../secrets/srv-n3.newt.env;
    format = "binary";
    path = "/run/secrets/newt.env";
    owner = "newt";
    group = "newt";
    mode = "0400";
  };
}
