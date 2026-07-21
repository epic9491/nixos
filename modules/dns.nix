{
  config,
  lib,
  ...
}:
let
  cfg = config.server.dns;
in
{
  options.server.dns.enable = lib.mkEnableOption "systemd-resolved with DNS-over-TLS";

  config = lib.mkIf cfg.enable {
    networking.nameservers = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
      "1.1.1.1#cloudflare-dns.com"
    ];

    services.resolved = {
      enable = true;
      settings.Resolve = {
        DNSOverTLS = "true";
        FallbackDNS = "";
      };
    };

    systemd.network.networks."99-ethernet-default-dhcp" = lib.mkIf config.networking.useDHCP {
      dhcpV4Config.UseDNS = false;
      dhcpV6Config.UseDNS = false;
      ipv6AcceptRAConfig.UseDNS = false;
    };
  };
}
