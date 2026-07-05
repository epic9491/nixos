{
  home-manager.users.newt = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.newt = {
        image = "docker.io/fosrl/newt:latest";
        autoStart = true;
        autoUpdate = "registry";
        environmentFile = [ "/run/secrets/newt.env" ];
        devices = [ "/dev/net/tun" ];
        network = "host";
        extraConfig.Service.RestartSec = 2;
      };
    };
  };

  age.secrets."newt.env" = {
    file = ../../../../secrets/srv-n1.newt.env.age;
    path = "/run/secrets/newt.env";
    owner = "newt";
    group = "newt";
    mode = "0400";
  };
}
