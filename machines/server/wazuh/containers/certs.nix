{
  systemd.tmpfiles.rules = [ "d /var/lib/wazuh/certs 0750 wazuh wazuh -" ];

  home-manager.users.wazuh =
    { pkgs, ... }:
    let
      certs = pkgs.writeText "certs.yml" ''
        nodes:
          indexer:
            - name: wazuh.indexer
              ip: wazuh.indexer
          server:
            - name: wazuh.manager
              ip:
                - wazuh.manager
                - wazuh.zorse-ruffe.ts.net
          dashboard:
            - name: wazuh.dashboard
              ip: wazuh.dashboard
      '';
    in
    {
      services.podman.containers.wazuh-certs = {
        image = "docker.io/wazuh/wazuh-certs-generator:0.0.4@sha256:369b4d58509aab074b188596870c81584f7120e653d9ef83c591f0f785dcf325";
        autoStart = true;
        entrypoint = "/bin/bash";
        # the tool leaves /certificates at 0500, which the non-root images cant traverse
        exec = "-c \"/entrypoint.sh && chmod 555 /certificates\"";
        volumes = [
          "/var/lib/wazuh/certs:/certificates"
          "${certs}:/config/certs.yml:ro"
        ];
        environment = {
          CERT_TOOL_VERSION = "4.14";
        };
        extraConfig = {
          Container = {
            NoNewPrivileges = true;
          };
          Service = {
            Type = "oneshot";
            RemainAfterExit = "yes";
            Restart = "no";
          };
          # regenerating would invalidate every cert the stack already trusts
          Unit.ConditionPathExists = "!/var/lib/wazuh/certs/root-ca.pem";
        };
      };
    };
}
