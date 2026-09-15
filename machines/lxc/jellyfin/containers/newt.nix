{
  home-manager.users.newt = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.newt = {
        image = "docker.io/fosrl/newt:1.17@sha256:3465d85200cceb0f46dad8e63a40b69ec043a81df66ed0c514714302e9b83dde";
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

  sops.secrets."newt.env" = {
    sopsFile = ../../../../secrets/jellyfin.newt.env;
    format = "binary";
    owner = "newt";
    group = "newt";
    mode = "0400";
  };
}
