{
  home-manager.users."uptime-kuma" = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.uptime-kuma = {
        image = "docker.io/louislam/uptime-kuma:1.23.17@sha256:3d632903e6af34139a37f18055c4f1bfd9b7205ae1138f1e5e8940ddc1d176f9";
        autoStart = true;
        ports = [
          "127.0.0.1:3001:3001"   # private
          "127.0.0.1:3002:3001"   # senseii
          "127.0.0.1:3003:3001"   # libresearch
          "127.0.0.1:3004:3001"   # pasted
        ];
        volumes = [ "/var/lib/uptime-kuma/data:/app/data:Z" ];
        extraConfig = {
          Container = {
            AddCapability = "SETGID SETUID";
            DropCapability = "ALL";
            NoNewPrivileges = true;
            Sysctl = ''"net.ipv4.ping_group_range=0 0"''; # <-- let the container ping without CAP_NET_RAW privs
          };
          Service.Restart = "always";
        };
      };
    };
  };
}
