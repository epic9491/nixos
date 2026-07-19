{
  backup.borgHome = {
    enable = true;
    name = "erebos";
    repo = "ssh://borg@100.106.154.7:22/mnt/backups/erebos_new";
    passFile = ../../../secrets/borg.erebos;
  };
}
