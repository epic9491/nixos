{
  users.manageLingering = true;

  users.users.wazuh = {
    isSystemUser = true;
    group = "wazuh";
    linger = true;
    home = "/var/lib/wazuh";
    createHome = true;
    autoSubUidGidRange = true;
  };

  users.groups.wazuh = { };

  home-manager.users.wazuh = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      networks.wazuh = { };
    };
  };
}
