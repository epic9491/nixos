{
  backup.pbs = {
    enable = true;
    name = "pangolin";
    namespace = "servers";
    repository = "servers@pbs!pangolin@100.69.69.100:backup";
    tokenFile = ../../../secrets/pangolin.pbs;
    keyFile = ../../../secrets/pangolin.pbs.key;
    extraExcludes = [ "/mnt" ];
  };
}
