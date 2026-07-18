{
  home-manager.users.newt = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.newt = {
        image = "docker.io/fosrl/newt:latest@sha256:60c78391e3b5cb8a260490fb26b8b7329ed5448077629da89a564af80d3a9fad";
        autoStart = true;
        environmentFile = [ "/run/secrets/newt.env" ];
        devices = [ "/dev/net/tun" ];
        extraPodmanArgs = [
          "--cap-add=NET_ADMIN"
          "--network=pasta:--map-host-loopback,169.254.1.2"
        ];
        extraConfig.Service.RestartSec = 2;
      };
    };
  };

  age.secrets."newt.env" = {
    file = ../../../../secrets/jellyfin.newt.env.age;
    path = "/run/secrets/newt.env";
    owner = "newt";
    group = "newt";
    mode = "0400";
  };
}
