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
    6443 # k3s API server
    10250 # kubelet
  ];

  sops.secrets."k3s-token" = {
    sopsFile = ../../../../secrets/k3s-token;
    format = "binary";
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
