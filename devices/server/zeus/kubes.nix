{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  services.k3s = {
    enable = true;
    tokenFile = "/secrets/k3s-token";
    role = "server";
    clusterInit = true;
  };
  networking.firewall.allowedUDPPorts = [ 8472 ]; # Flannel
  networking.firewall.allowedTCPPorts = [
    6443  # k3s API server
    10250 # kubelet
  ];
  age.secrets."k3s-token.age" = {
    file = ../../../secrets/k3s-token.age;
    path = "/secrets/k3s-token";
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
