{
  home-manager.users.owntracks = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;

      networks.owntracks = { };

      containers.recorder = {
        image = "docker.io/owntracks/recorder:latest";
        autoStart = true;
        autoUpdate = "registry";
        network = "owntracks.network";
        networkAlias = [ "recorder" ];
        ports = [ "127.0.0.1:8083:8083" ];
        volumes = [ "/var/lib/owntracks/recorder:/store:Z" ];
        environment = {
          # Disable MQTT, accept locations over HTTP only
          OTR_PORT = 0;
        };
        environmentFile = [ "/run/secrets/owntracks.env" ];
        extraConfig.Service.Restart = "always";
      };

      containers.frontend = {
        image = "docker.io/owntracks/frontend:latest";
        autoStart = true;
        autoUpdate = "registry";
        network = "owntracks.network";
        networkAlias = [ "frontend" ];
        ports = [ "127.0.0.1:8084:80" ];
        environment = {
          SERVER_HOST = "recorder";
          SERVER_PORT = 8083;
        };
        extraConfig = {
          Service.Restart = "always";
          Unit = {
            After = [ "podman-recorder.service" ];
            Wants = [ "podman-recorder.service" ];
          };
        };
      };

      containers.cloudflared = {
        image = "docker.io/cloudflare/cloudflared:latest";
        autoStart = true;
        autoUpdate = "registry";
        network = "owntracks.network";
        exec = "tunnel --no-autoupdate run";
        environmentFile = [ "/run/secrets/owntracks-cloudflared.env" ];
        extraConfig = {
          Service.Restart = "always";
          Unit = {
            After = [ "podman-recorder.service" ];
            Wants = [ "podman-recorder.service" ];
          };
        };
      };
    };
  };

  age.secrets."owntracks.env" = {
    file = ../../../../secrets/srv-n1.owntracks.env.age;
    path = "/run/secrets/owntracks.env";
    owner = "owntracks";
    group = "owntracks";
    mode = "0400";
  };

  age.secrets."owntracks-cloudflared.env" = {
    file = ../../../../secrets/srv-n1.owntracks-cloudflared.env.age;
    path = "/run/secrets/owntracks-cloudflared.env";
    owner = "owntracks";
    group = "owntracks";
    mode = "0400";
  };
}
