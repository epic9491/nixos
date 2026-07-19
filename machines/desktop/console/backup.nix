{
  backup.pbs = {
    enable = true;
    name = "console";
    namespace = "workstations";
    repository = "workstations@pbs!console@192.168.0.216:backup";
    tokenFile = ../../../secrets/console.pbs;
    extraExcludes = [ "/mnt" ];
  };
}
