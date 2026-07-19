{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.borgbackup.jobs.prometheus-home = {
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
    encryption.passCommand = "cat /run/secrets/borg.prometheus";
    environment.BORG_RSH = "ssh -i /home/gumbo/.ssh/borg";
    repo = "ssh://borg@100.106.154.7:22/mnt/backups/thinkpad_new";
    compression = "auto,zstd";
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 3;
    };
    startAt = [ ];
  };

  sops.secrets."borg.prometheus" = {
    sopsFile = ../../../secrets/borg.prometheus;
    format = "binary";
    owner = "gumbo";
    group = "users";
    mode = "0400";
  };
}
