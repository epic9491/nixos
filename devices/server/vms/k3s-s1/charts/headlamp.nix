{ config, lib, pkgs, ... }:
{
  services.k3s = {
    autoDeployCharts.headlamp = {
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
          port = 4446;
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

  networking.firewall.allowedTCPPorts = [ 30000 ];
}
