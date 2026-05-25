{ config, lib, pkgs, ... }:
{
    services.k3s.autoDeployCharts.grafana = {
    enable = true;
    name = "grafana";
    repo = "https://grafana.github.io/helm-charts";
    version = "10.5.15";
    hash = "sha256-wIyHlpJwQC59UiftuDha9nzDLuNIF7/4l3OtAjA7XXk=";
    targetNamespace = "monitoring";
    createNamespace = true;
    values = {
      service = {
        type = "NodePort";
        nodePort = 30003;
      };
      admin.existingSecret = "grafana-auth";
      sidecar.datasources.enabled = true;
    };
  };

  age.secrets."grafana-auth-s1.age" = {
    file = ../../../../../secrets/grafana-auth-s1.age;
    path = "/var/lib/rancher/k3s/server/manifests/grafana-auth.yaml";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  age.secrets."grafana-datasources-s1.age" = {
    file = ../../../../../secrets/grafana-datasources-s1.age;
    path = "/var/lib/rancher/k3s/server/manifests/grafana-datasources.yaml";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  networking.firewall.allowedTCPPorts = [ 30003 ];
}
