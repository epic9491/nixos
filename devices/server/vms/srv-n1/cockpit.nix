{ ... }:
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
}
