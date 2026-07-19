{
  backup.pbs = {
    enable = true;
    name = "git";
    namespace = "servers";
    repository = "servers@pbs!git@100.69.69.100:backup";
    tokenFile = ../../../secrets/git.pbs;
    keyFile = ../../../secrets/git.pbs.key;
    extraAfter = [ "tailscaled.service" ];
    extraRequires = [ "tailscaled.service" ];
  };
}
