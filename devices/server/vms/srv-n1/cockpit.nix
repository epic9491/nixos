{ pkgs, ... }:
{
  services.cockpit = {
    enable = true;
    openFirewall = false;
    allowed-origins = [
      "https://srv-n1.zorse-ruffe.ts.net"
      "https://srv-n1.zorse-ruffe.ts.net:443"
    ];
    settings = {
      WebService = {
        ProtocolHeader = "X-Forwarded-Proto";
      };
    };
  };

  services.tailscale = {
    enable = true;
    permitCertUid = "root";
  };

  systemd.services.tailscale-serve-cockpit = {
    description = "Expose Cockpit via tailscale serve";
    after = [ "tailscaled.service" "cockpit.socket" ];
    requires = [ "tailscaled.service" ];
    bindsTo = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.tailscale}/bin/tailscale serve --bg --https=443 localhost:9090";
      ExecStop = "${pkgs.tailscale}/bin/tailscale serve --https=443 off";
    };
  };
}
