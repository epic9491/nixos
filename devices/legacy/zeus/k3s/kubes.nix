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
    tokenFile = "/run/secrets/k3s-token";
    role = "server";
    clusterInit = true;
    nodeTaint = [ "CriticalAddonsOnly=true:NoExecute" ];
    extraFlags = toString [
      "--write-kubeconfig-mode=644"
    ];
  };

  networking.firewall.allowedUDPPorts = [ 8472 ]; # Flannel
  networking.firewall.allowedTCPPorts = [
    6443  # k3s API server
    10250 # kubelet
  ];

  age.secrets."k3s-token.age" = {
    file = ../../../../secrets/k3s-token.age;
    path = "/run/secrets/k3s-token";
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
