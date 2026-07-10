{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 80 443 ];
  };
}
