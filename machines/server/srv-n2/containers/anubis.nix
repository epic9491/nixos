{
  home-manager.users.anubis =
    { pkgs, ... }:
    let
      image = "ghcr.io/techarohq/anubis:v1.26.0@sha256:c23e455dea15bbd90b512f30aeaa45d76bfe492e001339433ce908dee2e311f8";

      # the searx.space checker runs a plain firefox UA, so it only passes by address
      policy = pkgs.writeTextDir "botPolicies.yaml" ''
        bots:
          - import: (data)/meta/default-config.yaml

          - name: searx-space-checker
            action: ALLOW
            remote_addresses:
              - 167.235.158.251/32
              - 2a01:4f8:1c1c:8fc2::/64

          - name: outside-search
            action: ALLOW
            expression: '!path.startsWith("/search")'

          - name: search
            action: CHALLENGE
            path_regex: ^/search
      '';

      hardening = {
        Container = {
          DropCapability = "ALL";
          NoNewPrivileges = true;
          ReadOnly = true;
        };
        Service.Restart = "always";
      };
    in
    {
      home.stateVersion = "25.05";

      services.podman = {
        enable = true;

        containers.anubis-libresearch = {
          inherit image;
          autoStart = true;
          ports = [ "127.0.0.1:8084:8080" ];
          extraPodmanArgs = [ "--network=pasta:--map-host-loopback,169.254.1.2" ];
          volumes = [ "${policy}:/data/cfg:ro" ];
          environment = {
            BIND = ":8080";
            TARGET = "http://169.254.1.2:8082";
            POLICY_FNAME = "/data/cfg/botPolicies.yaml";
            COOKIE_DOMAIN = "libresearch.space";
            DIFFICULTY = 4;
            METRICS_BIND = ":9090";
          };
          extraConfig = hardening;
        };

        containers.anubis-pasted = {
          inherit image;
          autoStart = true;
          ports = [ "127.0.0.1:8085:8080" ];
          extraPodmanArgs = [ "--network=pasta:--map-host-loopback,169.254.1.2" ];
          environment = {
            BIND = ":8080";
            TARGET = "http://169.254.1.2:8083";
            COOKIE_DOMAIN = "pasted.space";
            DIFFICULTY = 4;
            METRICS_BIND = ":9090";
          };
          extraConfig = hardening;
        };
      };
    };
}
