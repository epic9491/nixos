{ ... }:
{
  imports = [
    ../../../../modules/k3s-agent.nix
  ];
  cluster.k3sAgent = {
    enable = true;
    serverAddr = "https://100.118.40.82:6443";
  };
}
