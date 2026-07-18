{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.borgbackup.jobs.erebos-home = {
    paths = "/home/gumbo";
    exclude = [
      "/home/gumbo/.cache"
      "/home/gumbo/.nix-defexpr"
      "/home/gumbo/.nix-profile"
      "/home/gumbo/.mozilla"
      "/home/gumbo/.pki"
      "/home/gumbo/.steam"
      "/home/gumbo/.terraform.d"
      "/home/gumbo/.var"
    ];
    encryption.mode = "repokey";
    encryption.passCommand = "cat /run/agenix/borg.erebos.age";
    environment.BORG_RSH = "ssh -i /home/gumbo/.ssh/borg";
    repo = "ssh://borg@100.106.154.7:22/mnt/backups/erebos_new";
    compression = "auto,zstd";
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 3;
    };
    startAt = [ ];
  };

  age.secrets."borg.erebos.age" = {
    file = ../../../secrets/borg.erebos.age;
    path = "/run/agenix/borg.erebos.age";
    owner = "gumbo";
    group = "users";
    mode = "0400";
  };
}
