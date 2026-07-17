{
  home-manager.users.karakeep = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;

      networks.karakeep = { };

      containers.karakeep = {
        image = "ghcr.io/karakeep-app/karakeep:release@sha256:64d6a9bbf2d37b5c808cf06b5d87f1f1c7846fdd3844724145a9741aeb06fd31";
        autoStart = true;
        ports = [ "127.0.0.1:3000:3000" ];
        volumes = [ "/var/lib/karakeep/data:/data:Z" ];
        network = "karakeep.network";
        environmentFile = [ "/run/secrets/karakeep.env" ];
        environment = {
          MEILI_ADDR = "http://meilisearch:7700";
          BROWSER_WEB_URL = "http://chrome:9222";
          DATA_DIR = "/data";
        };
        extraPodmanArgs = [ "--memory=3g" ];
        extraConfig = {
          Service.Restart = "always";
          Unit = {
            After = [
              "podman-karakeep-chrome.service"
              "podman-karakeep-meilisearch.service"
            ];
            Wants = [
              "podman-karakeep-chrome.service"
              "podman-karakeep-meilisearch.service"
            ];
          };
        };
      };

      containers.karakeep-chrome = {
        image = "gcr.io/zenika-hub/alpine-chrome:124@sha256:1a0046448e0bb6c275c88f86e01faf0de62b02ec8572901256ada0a8c08be23f";
        autoStart = true;
        network = "karakeep.network";
        networkAlias = [ "chrome" ];
        exec = "--no-sandbox --disable-gpu --disable-dev-shm-usage --remote-debugging-address=0.0.0.0 --remote-debugging-port=9222 --hide-scrollbars";
        extraConfig.Service.Restart = "always";
      };

      containers.karakeep-meilisearch = {
        image = "docker.io/getmeili/meilisearch:v1.41.0@sha256:860fa4baed04ae1c235de870edab0c8006227546dea1bbb6411fbfc5e27cf1db";
        autoStart = true;
        network = "karakeep.network";
        networkAlias = [ "meilisearch" ];
        volumes = [ "/srv/karakeep/meili_data:/meili_data:Z" ];
        environmentFile = [ "/run/secrets/karakeep.env" ];
        environment = {
          MEILI_NO_ANALYTICS = "true";
        };
        extraConfig.Service.Restart = "always";
      };
    };
  };

  age.secrets."karakeep.env" = {
    file = ../../../../secrets/srv-n1.karakeep.env.age;
    path = "/run/secrets/karakeep.env";
    owner = "karakeep";
    group = "karakeep";
    mode = "0400";
  };
}
