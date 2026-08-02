{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.server.killswitch;

  chain = "vpn-killswitch";
  tables = [ "iptables" ] ++ lib.optional config.networking.enableIPv6 "ip6tables";

  apply = pkgs.writeShellScript "vpn-killswitch-apply" ''
    set -eu
    for ipt in ${lib.concatStringsSep " " tables}; do
      bin=${pkgs.iptables}/bin/$ipt

      # reject lands first so a re-run never leaves the chain permissive
      $bin -w -N ${chain} 2>/dev/null || $bin -w -F ${chain}
      $bin -w -A ${chain} -j REJECT
      $bin -w -I ${chain} -o ${cfg.lanInterface} -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN
      $bin -w -I ${chain} -o ${cfg.vpnInterface} -j RETURN
      $bin -w -I ${chain} -o lo -j RETURN

      $bin -w -C OUTPUT -m owner --uid-owner ${toString cfg.uid} -j ${chain} 2>/dev/null \
        || $bin -w -I OUTPUT 1 -m owner --uid-owner ${toString cfg.uid} -j ${chain}
    done
  '';
in
{
  options.server.killswitch = {
    enable = lib.mkEnableOption "confine one uid's egress to the VPN interface";

    uid = lib.mkOption {
      type = lib.types.int;
    };

    vpnInterface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
    };

    lanInterface = lib.mkOption {
      type = lib.types.str;
      default = "eth0";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.vpn-killswitch = {
      description = "Confine uid ${toString cfg.uid} egress to ${cfg.vpnInterface}";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-pre.target" ];
      before = [ "network-pre.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = apply;
      };
    };

    # no ExecStop: the rules outlive a stopped unit rather than failing open
    systemd.services."user@${toString cfg.uid}" = {
      overrideStrategy = "asDropin";
      wants = [ "vpn-killswitch.service" ];
      after = [ "vpn-killswitch.service" ];
    };
  };
}
