{
  home-manager.users.newt =
    { ... }:
    {
      home.stateVersion = "25.05";

      services.podman = {
        enable = true;

        containers.newt = {
          image = "docker.io/fosrl/newt:1.16@sha256:345fdeb369be6608d82c41d70637636c78b2c04a6112ff6ec20fc21c48afc899";
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
