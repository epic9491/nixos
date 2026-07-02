{
  home-manager.users.karakeep = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;

      networks.karakeep = { };

      containers.karakeep = {
        image = "ghcr.io/karakeep-app/karakeep:release";
        autoStart = true;
        autoUpdate = "registry";
        ports = [ "127.0.0.1:3000:3000" ];
        volumes = [ "/var/lib/karakeep/data:/data:Z" ];
        network = "karakeep.network";
        environmentFile = [ "/run/secrets/karakeep.env" ];
        environment = {
          MEILI_ADDR = "http://meilisearch:7700";
          BROWSER_WEB_URL = "http://chrome:9222";
          OLLAMA_BASE_URL = "http://100.69.0.2:11434";
          INFERENCE_TEXT_MODEL = "qwen3:8b";
          INFERENCE_IMAGE_MODEL = "qwen3:8b";
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
        image = "gcr.io/zenika-hub/alpine-chrome:124";
        autoStart = true;
        network = "karakeep.network";
        networkAlias = [ "chrome" ];
        exec = "--no-sandbox --disable-gpu --disable-dev-shm-usage --remote-debugging-address=0.0.0.0 --remote-debugging-port=9222 --hide-scrollbars";
        extraConfig.Service.Restart = "always";
      };

      containers.karakeep-meilisearch = {
        image = "docker.io/getmeili/meilisearch:v1.13.3";
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
    file = ../../../../../secrets/srv-n1.karakeep.env.age;
    path = "/run/secrets/karakeep.env";
    owner = "karakeep";
    group = "karakeep";
    mode = "0400";
  };
}
