{ ... }:
{
  networking.bridges.br0.interfaces = [ "eno2" ];

  networking.interfaces.br0 = {
    ipv4.addresses = [{
      address = "192.168.0.157";
      prefixLength = 24;
    }];
  };

  networking.defaultGateway = "192.168.0.1";
}
