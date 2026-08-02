{
  home-manager.users.anubis =
    { pkgs, ... }:
    let
      image = "ghcr.io/techarohq/anubis:v1.26.2@sha256:f7af22049b33ce1cdefa903f0920f8306aaf61c10e85c03dda708f264e163d51";

      # keep badges open 
      policy = pkgs.writeTextDir "botPolicies.yaml" ''
        bots:
          - import: (data)/meta/default-config.yaml

          - name: status-badge
            action: ALLOW
            expression: 'path.startsWith("/api/badge/")'
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

        containers.anubis-status-libresearch = {
          inherit image;
          autoStart = true;
          ports = [ "127.0.0.1:8088:8080" ];
          extraPodmanArgs = [ "--network=pasta:--map-host-loopback,169.254.1.2" ];
          volumes = [ "${policy}:/data/cfg:ro" ];
          environment = {
            BIND = ":8080";
            TARGET = "http://169.254.1.2:3003";
            POLICY_FNAME = "/data/cfg/botPolicies.yaml";
            DIFFICULTY = 4;
          };
          extraConfig = hardening;
        };

        containers.anubis-status-pasted = {
          inherit image;
          autoStart = true;
          ports = [ "127.0.0.1:8089:8080" ];
          extraPodmanArgs = [ "--network=pasta:--map-host-loopback,169.254.1.2" ];
          volumes = [ "${policy}:/data/cfg:ro" ];
          environment = {
            BIND = ":8080";
            TARGET = "http://169.254.1.2:3004";
            POLICY_FNAME = "/data/cfg/botPolicies.yaml";
            DIFFICULTY = 4;
          };
          extraConfig = hardening;
        };
      };
    };
}
