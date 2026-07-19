{
  config,
  lib,
  pkgs,
  ...
}:
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
  sops.secrets."newt-auth" = {
    sopsFile = ../../../../../secrets/newt-auth;
    format = "binary";
    path = "/var/lib/rancher/k3s/server/manifests/newt-auth.yaml";
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
