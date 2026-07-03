{
  home-manager.users.adguard = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.adguard = {
        image = "docker.io/adguard/adguardhome:latest";
        autoStart = true;
        autoUpdate = "registry";
        ports = [
          "100.69.69.210:53:53/tcp"
          "100.69.69.210:53:53/udp"
          "[fd7a:115c:a1e0::7e36:ab2a]:53:53/tcp"
          "[fd7a:115c:a1e0::7e36:ab2a]:53:53/udp"
          "127.0.0.1:80:80"
        ];
        volumes = [
          "/var/lib/adguard/work:/opt/adguardhome/work:Z"
          "/var/lib/adguard/conf:/opt/adguardhome/conf:Z"
        ];
        extraConfig.Service.Restart = "always";
      };
    };
  };
}
