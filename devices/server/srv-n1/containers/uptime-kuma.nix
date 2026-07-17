{
  home-manager.users."uptime-kuma" = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.uptime-kuma = {
        image = "docker.io/louislam/uptime-kuma:latest@sha256:3d632903e6af34139a37f18055c4f1bfd9b7205ae1138f1e5e8940ddc1d176f9";
        autoStart = true;
        ports = [ "127.0.0.1:3001:3001" ];
        volumes = [ "/var/lib/uptime-kuma/data:/app/data:Z" ];
        extraConfig.Service.Restart = "always";
      };
    };
  };
}
