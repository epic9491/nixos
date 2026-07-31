{
  home-manager.users."uptime-kuma" = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.uptime-kuma = {
        image = "docker.io/louislam/uptime-kuma:2.4.0@sha256:91e963bfda569ba115206e843febb446f473ab525add4e08b2b9e3beffa16985";
        autoStart = true;
        ports = [
          "127.0.0.1:3001:3001" # private
          "127.0.0.1:3002:3001" # senseii
          "127.0.0.1:3003:3001" # libresearch
          "127.0.0.1:3004:3001" # pasted
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
