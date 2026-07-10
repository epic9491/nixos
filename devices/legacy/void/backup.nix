{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.borgbackup.jobs.void-home = {
    paths = [
      "/home/gumbo"
      "/var/lib/nixos-containers/tuwunel"
    ];
    exclude = [
      "/home/gumbo/.cache"
      "/home/gumbo/.nix-defexpr"
      "/home/gumbo/.nix-profile"
      "/home/gumbo/.mozilla"
      "/home/gumbo/.pki"
      "/home/gumbo/.steam"
      "/home/gumbo/.terraform.d"
      "/home/gumbo/.var"
      "/home/gumbo/matrix"
    ];
    encryption.mode = "repokey";
    encryption.passCommand = "cat /run/agenix/borg.void.age";
    environment.BORG_RSH = "ssh -i /home/gumbo/.ssh/borg";
    repo = "ssh://borg@100.106.154.7:22/mnt/backups/void_home";
    compression = "auto,zstd";
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 3;
    };
    preHook = ''
      systemctl stop container@tuwunel
    '';
    postHook = ''
      systemctl start container@tuwunel
      exit $exitStatus
    '';
    startAt = "daily";
  };

  age.secrets."borg.void.age" = {
    file = ../../../secrets/borg.void.age;
    path = "/run/agenix/borg.void.age";
    owner = "gumbo";
    group = "users";
    mode = "0400";
  };
}
