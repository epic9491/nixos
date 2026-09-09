{
  config,
  lib,
  ...
}:
let
  cfg = config.server.ban;

  chain = "banned";

  isV6 = a: lib.hasInfix ":" a;
  v4 = lib.filter (a: !isV6 a) cfg.addresses;
  v6 = lib.filter isV6 cfg.addresses;

  # nixos-fw accepts the published port first, so the jump has to sit ahead of it
  apply = ipt: addrs: ''
    ${ipt} -w -N ${chain} 2>/dev/null || ${ipt} -w -F ${chain}
    ${lib.concatMapStrings (a: "${ipt} -w -A ${chain} -s ${a} -j DROP\n") addrs}
    ${ipt} -w -C INPUT -j ${chain} 2>/dev/null || ${ipt} -w -I INPUT 1 -j ${chain}
  '';

  teardown = ipt: ''
    ${ipt} -w -D INPUT -j ${chain} 2>/dev/null || true
    ${ipt} -w -F ${chain} 2>/dev/null || true
    ${ipt} -w -X ${chain} 2>/dev/null || true
  '';
in
{
  options.server.ban = {
    enable = lib.mkEnableOption "drop traffic from abusive addresses";

    addresses = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "104.28.0.0/16"
        "2600:1900::/28"
      ];
      description = "bare IPs or CIDRs to drop; v4 and v6 are split apart automatically";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.extraCommands =
      apply "iptables" v4 + lib.optionalString config.networking.enableIPv6 (apply "ip6tables" v6);

    networking.firewall.extraStopCommands =
      teardown "iptables" + lib.optionalString config.networking.enableIPv6 (teardown "ip6tables");
  };
}
