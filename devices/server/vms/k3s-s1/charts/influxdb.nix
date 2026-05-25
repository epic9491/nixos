{ config, lib, pkgs, ... }:
{
    services.k3s.autoDeployCharts.influxdb = {
    enable = true;
    name = "influxdb2";
    repo = "https://helm.influxdata.com/";
    version = "2.1.2";
    hash = "sha256-Haix6KK5PprLsLyanAo+UmWBzN5L8nF4XQlpntIZygg=";
    targetNamespace = "monitoring";
    createNamespace = true;
    values = {
      service = {
        type = "NodePort";
        nodePort = 30002;
      };
      adminUser = {
        organization = "homelab";
        bucket = "proxmox";
        user = "admin";
        existingSecret = "influxdb-auth";
      };
      persistence.enabled = true;
      persistence.size = "10Gi";
    };
  };

  age.secrets."influx-auth-s1.age" = {
    file = ../../../../../secrets/influx-auth-s1.age;
    path = "/var/lib/rancher/k3s/server/manifests/influx-auth.yaml";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  networking.firewall.allowedTCPPorts = [ 30002 ];
}
