{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.server.ntp;

  iptables = config.networking.firewall.package;

  # chrony counts packets, not bytes
  accounting = pkgs.writeShellScript "ntp-accounting" ''
    set -euo pipefail

    counters() {
      "$1" -c -t filter | awk -v family="$2" '
        $NF ~ /^ntp-acct-(in|out)$/ {
          direction = $NF == "ntp-acct-in" ? "rx" : "tx"
          split(substr($1, 2, length($1) - 2), n, ":")
          printf "ntp_wire_packets_total{direction=\"%s\",family=\"%s\"} %s\n", direction, family, n[1]
          printf "ntp_wire_bytes_total{direction=\"%s\",family=\"%s\"} %s\n", direction, family, n[2]
        }'
    }

    tmp=$(mktemp /var/lib/ntp-accounting/.ntp.XXXXXX)
    trap 'rm -f "$tmp"' EXIT

    {
      echo "# TYPE ntp_wire_packets_total counter"
      echo "# TYPE ntp_wire_bytes_total counter"
      counters ${iptables}/bin/iptables-save ipv4
      counters ${iptables}/bin/ip6tables-save ipv6
    } > "$tmp"

    chmod 644 "$tmp"
    mv "$tmp" /var/lib/ntp-accounting/ntp.prom
  '';
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

        # only the unix socket gets full access, so udp/323 needs these named
        opencommands activity manual rtcdata smoothing sourcename sources sourcestats tracking serverstats clients
      '';

      # reload the dumped histories so a rebuild doesnt cost a fresh resync
      extraFlags = [ "-r" ];
    };

    networking.firewall = {
      allowedUDPPorts = [ 123 ];

      # the chains stay empty, so the jump rules only carry counters
      extraCommands = ''
        ip46tables -N ntp-acct-in 2>/dev/null || true
        ip46tables -N ntp-acct-out 2>/dev/null || true
        ip46tables -C INPUT -p udp --dport 123 -j ntp-acct-in 2>/dev/null || ip46tables -I INPUT 1 -p udp --dport 123 -j ntp-acct-in
        ip46tables -C OUTPUT -p udp --sport 123 -j ntp-acct-out 2>/dev/null || ip46tables -I OUTPUT 1 -p udp --sport 123 -j ntp-acct-out
      '';

      extraStopCommands = ''
        ip46tables -D INPUT -p udp --dport 123 -j ntp-acct-in 2>/dev/null || true
        ip46tables -D OUTPUT -p udp --sport 123 -j ntp-acct-out 2>/dev/null || true
        ip46tables -F ntp-acct-in 2>/dev/null || true
        ip46tables -X ntp-acct-in 2>/dev/null || true
        ip46tables -F ntp-acct-out 2>/dev/null || true
        ip46tables -X ntp-acct-out 2>/dev/null || true
      '';
    };

    systemd.tmpfiles.rules = [ "d /var/lib/ntp-accounting 0755 root root - -" ];

    systemd.services.ntp-accounting = {
      description = "dump the udp/123 counters for the node exporter";
      after = [ "firewall.service" ];
      path = [
        pkgs.coreutils
        pkgs.gawk
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = accounting;
      };
    };

    systemd.timers.ntp-accounting = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "30s";
        OnUnitActiveSec = "30s";
        Unit = "ntp-accounting.service";
      };
    };
  };
}
