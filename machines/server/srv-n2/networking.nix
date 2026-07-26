{
  # ovh puts the gateway outside the routed /128
  systemd.network.networks."99-ethernet-default-dhcp" = {
    address = [ "2607:5300:205:200::6e98/128" ];
    routes = [
      {
        Gateway = "2607:5300:205:200::1";
        GatewayOnLink = true;
      }
    ];
    networkConfig.IPv6AcceptRA = false;
  };
}
