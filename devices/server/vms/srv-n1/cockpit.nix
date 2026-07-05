{ lib, ... }:
{
  services.cockpit = {
    enable = true;
    openFirewall = false;
  };

  systemd.sockets.cockpit.listenStreams = lib.mkForce [ "127.0.0.1:9090" ];

  age.secrets."cockpit.env" = {
    file = ../../../../secrets/srv-n1.cockpit.env.age;
    path = "/run/secrets/cockpit.env";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  system.activationScripts.cockpitConfig = {
    deps = [
      "agenixInstall"
      "etc"
    ];
    text = ''
      source /run/secrets/cockpit.env
      rm -f /etc/cockpit/cockpit.conf
      cat > /etc/cockpit/cockpit.conf <<EOF
      [WebService]
      Origins = https://$COCKPIT_DOMAIN
      ProtocolHeader = X-Forwarded-Proto
      LoginTo = false
      EOF
    '';
  };
}
