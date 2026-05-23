{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  networking.firewall.allowedUDPPorts = [ 8472 ]; # Flannel
  services.k3s = {
    enable = true;
    role = "agent";
    tokenFile = /run/secrets/k3s-token;
    serverAddr = "https://100.118.40.82:6443";
  };
  age.secrets."k3s-token.age" = {
    file = ../../../../secrets/k3s-token.age;
    path = "/run/secrets/k3s-token";
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
