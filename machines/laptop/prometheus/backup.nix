{
  backup.borgHome = {
    enable = true;
    name = "prometheus";
    repo = "ssh://borg@100.106.154.7:22/mnt/backups/thinkpad_new";
    passFile = ../../../secrets/borg.prometheus;
  };
}
