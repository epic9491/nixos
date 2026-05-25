{ config, lib, pkgs, ... }:
{
  services.k3s.autoDeployCharts.newt = {
    enable = true;
    name = "newt";
    repo = "https://charts.fossorial.io";
    version = "1.5.0";
    hash = "sha256-8bXoH+Tg8wIsYcxwJhzQOX/SqOKVNjBxj9gXNMsazgg=";
    targetNamespace = "pangolin";
    createNamespace = true;
    values = {
      newtInstances = [
        {
          name = "main-tunnel";
          enabled = true;
          auth = {
            existingSecretName = "newt-auth";
          };
          replicas = 1;
        }
      ];
    };
  };
  age.secrets."newt-auth.age" = {
    file = ../../../../../secrets/newt-auth.age;
    path = "/var/lib/rancher/k3s/server/manifests/newt-auth.yaml";
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
