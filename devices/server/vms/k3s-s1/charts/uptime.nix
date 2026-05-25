{ config, lib, pkgs, ... }:
{
  services.k3s.autoDeployCharts.uptime-kuma = {
    enable = true;
    name = "uptime-kuma";
    repo = "https://helm.irsigler.cloud";
    version = "4.1.0";
    hash = "sha256-RDzmSioccOdvIyuN5MJY/X2SOgprBYdZ0ZCMHxCzUf4=";
    targetNamespace = "uptime-kuma";
    createNamespace = true;
    values = {
      service = {
        type = "NodePort";
        nodePort = 30001;
      };
      volume = {
        enabled = true;
        size = "2Gi";
        storageClassName = "local-path";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 30001 ];
}
