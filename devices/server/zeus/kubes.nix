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
    autoDeployCharts = {
      headlamp = {
        enable = true;
        name = "headlamp";
        repo = "https://kubernetes-sigs.github.io/headlamp/";
        version = "0.42.0";
        hash = "sha256-EBS8lsdpYABkXSm7cDNthj2VGysTBoMiDbGXNDi3bEA=";
        targetNamespace = "kube-system";
        createNamespace = true;
        values = {
          service = {
            type = "NodePort";
            nodePort = 30000;
          };
        };
      };
    };
    manifests = {
      headlamp-user-sa.content = {
        apiVersion = "v1";
        kind = "ServiceAccount";
        metadata = {
          name = "headlamp-user";
          namespace = "kube-system";
        };
      };
      headlamp-user-binding.content = {
        apiVersion = "rbac.authorization.k8s.io/v1";
        kind = "ClusterRoleBinding";
        metadata.name = "headlamp-user";
        roleRef = {
          apiGroup = "rbac.authorization.k8s.io";
          kind = "ClusterRole";
          name = "cluster-admin";
        };
        subjects = [{
          kind = "ServiceAccount";
          name = "headlamp-user";
          namespace = "kube-system";
        }];
      };
      headlamp-user-token.content = {
        apiVersion = "v1";
        kind = "Secret";
        metadata = {
          name = "headlamp-user-token";
          namespace = "kube-system";
          annotations."kubernetes.io/service-account.name" = "headlamp-user";
        };
        type = "kubernetes.io/service-account-token";
      };
    };
  };
  networking.firewall.allowedUDPPorts = [ 8472 ]; # Flannel
  networking.firewall.allowedTCPPorts = [
    6443  # k3s API server
    10250 # kubelet
    30000 # headlamp
  ];
  age.secrets."k3s-token.age" = {
    file = ../../../secrets/k3s-token.age;
    path = "/run/secrets/k3s-token";
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
