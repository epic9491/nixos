{
  config,
  lib,
  ...
}:
let
  cfg = config.server.ntp;
in
{
  options.server.ntp.enable = lib.mkEnableOption "chrony serving the public ntp pool";

  config = lib.mkIf cfg.enable {
    services.chrony = {
      enable = true;

      # pool members cant take pool.ntp.org upstream, so these are pinned by hand
      servers = [
        "time.cloudflare.com"
        "virginia.time.system76.com"
        "ohio.time.system76.com"
        "ptbtime1.ptb.de"
      ];

      # every server above speaks NTS-KE on 4460, so authenticate all of them
      enableNTS = true;

      extraConfig = ''
        allow
        ratelimit interval 1 burst 16
        clientloglimit 100000000
        leapseclist /etc/zoneinfo/leap-seconds.list
        dumpdir /var/lib/chrony
      '';

      # reload the dumped histories so a rebuild doesnt cost a fresh resync
      extraFlags = [ "-r" ];
    };

    networking.firewall.allowedUDPPorts = [ 123 ];
  };
}
