{
  services.crowdsec-firewall-bouncer = {
    enable = true;
    createRulesets = true;

    registerBouncer.enable = false;
    secrets.apiKeyPath = "/run/secrets/crowdsec-firewall-bouncer.key";

    settings = {
      mode = "iptables";
      api_url = "http://127.0.0.1:8080";
      update_frequency = "10s";
      disable_ipv6 = true;
      # cannot filter by decision type; keep in sync with forge_ban
      scenarios_containing = [ "gitea" ];
      iptables_chains = [ "INPUT" ];
      log_mode = "stdout";
      log_level = "info";
    };
  };

  age.secrets."crowdsec-firewall-bouncer.key" = {
    file = ../../../secrets/srv-n2.crowdsec-firewall-bouncer.key.age;
    path = "/run/secrets/crowdsec-firewall-bouncer.key";
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
