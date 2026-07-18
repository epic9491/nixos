{ ... }:
{
  imports = [
    ../../../../modules/k3s-agent.nix
  ];
  cluster.k3sAgent = {
    enable = true;
    serverAddr = "https://100.69.1.10:6443";
  };
}
