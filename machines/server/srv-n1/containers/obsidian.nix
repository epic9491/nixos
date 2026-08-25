{
  home-manager.users.obsidian = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;

      networks.obsidian = { };

      containers.couchdb = {
        image = "docker.io/library/couchdb:3.5@sha256:9ea24cbd76522fe845d1c32c7fd1dcfc8a3ba73dcc4817d62f8a7f7f1dfaffe3";
        autoStart = true;
        network = "obsidian.network";
        networkAlias = [ "couchdb" ];
        ports = [ "127.0.0.1:5984:5984" ];
        volumes = [
          "/var/lib/obsidian/data:/opt/couchdb/data:Z"
          "/var/lib/obsidian/etc:/opt/couchdb/etc/local.d:Z"
        ];
        environmentFile = [ "/run/secrets/obsidian-couchdb.env" ];
        userNS = "keep-id:uid=5984,gid=5984";
        extraConfig = {
          Container = {
            AddCapability = "CHOWN SETGID SETUID";
            DropCapability = "ALL";
            NoNewPrivileges = true;
          };
          Service.Restart = "always";
        };
      };

      containers.cloudflared = {
        image = "docker.io/cloudflare/cloudflared:2026.8.2@sha256:0aa26e284f05e6c77ae375b8c9c11d9eb6a448fb7bcd8d40f31cb6176189eb38";
        autoStart = true;
        network = "obsidian.network";
        exec = "tunnel --no-autoupdate run";
        environmentFile = [ "/run/secrets/obsidian-cloudflared.env" ];
        extraConfig = {
          Container = {
            DropCapability = "ALL";
            NoNewPrivileges = true;
          };
          Service.Restart = "always";
          Unit = {
            After = [ "podman-couchdb.service" ];
            Wants = [ "podman-couchdb.service" ];
          };
        };
      };
    };
  };

  sops.secrets."obsidian-couchdb.env" = {
    sopsFile = ../../../../secrets/srv-n1.obsidian-couchdb.env;
    format = "binary";
    owner = "obsidian";
    group = "obsidian";
    mode = "0400";
  };

  sops.secrets."obsidian-cloudflared.env" = {
    sopsFile = ../../../../secrets/srv-n1.obsidian-cloudflared.env;
    format = "binary";
    owner = "obsidian";
    group = "obsidian";
    mode = "0400";
  };
}
