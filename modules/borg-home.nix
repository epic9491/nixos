{
  config,
  lib,
  ...
}:
let
  cfg = config.backup.borgHome;
in
{
  options.backup.borgHome = {
    enable = lib.mkEnableOption "borg backup of /home/gumbo";

    name = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Job suffix, and the sops secret name borg.<name>.";
    };

    repo = lib.mkOption {
      type = lib.types.str;
      description = "Borg repository URL.";
    };

    passFile = lib.mkOption {
      type = lib.types.path;
      description = "Encrypted sops file holding the repokey passphrase.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.borgbackup.jobs."${cfg.name}-home" = {
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
      encryption.passCommand = "cat /run/secrets/borg.${cfg.name}";
      environment.BORG_RSH = "ssh -i /home/gumbo/.ssh/borg";
      repo = cfg.repo;
      compression = "auto,zstd";
      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 3;
      };
      startAt = [ ];
    };

    sops.secrets."borg.${cfg.name}" = {
      sopsFile = cfg.passFile;
      format = "binary";
      owner = "gumbo";
      group = "users";
      mode = "0400";
    };
  };
}
