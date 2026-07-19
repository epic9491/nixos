{
  backup.pbs = {
    enable = true;
    name = "srv-n1";
    namespace = "servers";
    repository = "servers@pbs!srv-n1@192.168.0.216:backup";
    tokenFile = ../../../secrets/srv-n1.pbs;
    keyFile = ../../../secrets/srv-n1.pbs.key;
    extraExcludes = [ "/mnt" ];
  };
}
