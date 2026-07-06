{
  home-manager.users.obsidian = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;

      networks.obsidian = { };

      containers.couchdb = {
        image = "docker.io/library/couchdb:3.5";
        autoStart = true;
        autoUpdate = "registry";
        network = "obsidian.network";
        networkAlias = [ "couchdb" ];
        ports = [ "127.0.0.1:5984:5984" ];
        volumes = [
          "/var/lib/obsidian/data:/opt/couchdb/data:Z"
          "/var/lib/obsidian/etc:/opt/couchdb/etc/local.d:Z"
        ];
        environmentFile = [ "/run/secrets/obsidian-couchdb.env" ];
        userNS = "keep-id:uid=5984,gid=5984";
        extraConfig.Service.Restart = "always";
      };

      containers.cloudflared = {
        image = "docker.io/cloudflare/cloudflared:latest";
        autoStart = true;
        autoUpdate = "registry";
        network = "obsidian.network";
        exec = "tunnel --no-autoupdate run";
        environmentFile = [ "/run/secrets/obsidian-cloudflared.env" ];
        extraConfig = {
          Service.Restart = "always";
          Unit = {
            After = [ "podman-couchdb.service" ];
            Wants = [ "podman-couchdb.service" ];
          };
        };
      };
    };
  };

  age.secrets."obsidian-couchdb.env" = {
    file = ../../../../secrets/srv-n1.obsidian-couchdb.env.age;
    path = "/run/secrets/obsidian-couchdb.env";
    owner = "obsidian";
    group = "obsidian";
    mode = "0400";
  };

  age.secrets."obsidian-cloudflared.env" = {
    file = ../../../../secrets/srv-n1.obsidian-cloudflared.env.age;
    path = "/run/secrets/obsidian-cloudflared.env";
    owner = "obsidian";
    group = "obsidian";
    mode = "0400";
  };
}
