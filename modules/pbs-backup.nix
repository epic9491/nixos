{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.backup.pbs;

  excludes = cfg.extraExcludes ++ [
    "/var/cache"
    "/var/tmp"
    "/var/lib/systemd/coredump"
    "'/home/*/.cache'"
  ];

  args = [
    "root.pxar:/"
  ]
  ++ lib.optional (cfg.keyFile != null) "--keyfile /run/secrets/${cfg.name}.key"
  ++ map (e: "--exclude ${e}") excludes
  ++ [
    "--ns ${cfg.namespace}/${cfg.name} --backup-id ${cfg.name}"
    "--change-detection-mode=metadata"
  ];
in
{
  options.backup.pbs = {
    enable = lib.mkEnableOption "Proxmox Backup Server client backup";

    name = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Backup id, and prefix for the sops secret names.";
    };

    namespace = lib.mkOption {
      type = lib.types.str;
      description = "PBS namespace the snapshot lands in, e.g. servers or workstations.";
    };

    repository = lib.mkOption {
      type = lib.types.str;
      description = "Full PBS_REPOSITORY string, used verbatim.";
    };

    fingerprint = lib.mkOption {
      type = lib.types.str;
      default = "8c:93:31:12:89:30:25:95:d5:93:c5:e5:da:f1:c2:88:55:bc:e1:83:4f:ca:b1:26:5c:dd:52:9f:b6:a1:b4:18";
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Encrypted sops file holding the API token.";
    };

    keyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Encrypted sops file holding the client encryption key. Null disables encryption.";
    };

    extraExcludes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    extraAfter = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    extraRequires = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "${cfg.name}.token" = {
        sopsFile = cfg.tokenFile;
        format = "binary";
        owner = "root";
        group = "root";
        mode = "0400";
      };
    }
    // lib.optionalAttrs (cfg.keyFile != null) {
      "${cfg.name}.key" = {
        sopsFile = cfg.keyFile;
        format = "binary";
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };

    environment.systemPackages = [ pkgs.proxmox-backup-client ];

    systemd.services.pbs-backup = {
      description = "Proxmox Backup Server backup";
      after = [ "network-online.target" ] ++ cfg.extraAfter;
      wants = [ "network-online.target" ];
      requires = cfg.extraRequires;

      environment = {
        PBS_REPOSITORY = cfg.repository;
        PBS_FINGERPRINT = cfg.fingerprint;
      };

      serviceConfig = {
        Type = "oneshot";
        LimitNOFILE = 65536;
        LoadCredential = [ "token:${config.sops.secrets."${cfg.name}.token".path}" ];
      };

      script = ''
        export PBS_PASSWORD="$(cat "$CREDENTIALS_DIRECTORY/token")"
        exec ${pkgs.proxmox-backup-client}/bin/proxmox-backup-client backup \
          ${lib.concatStringsSep " \\\n  " args}
      '';
    };

    systemd.timers.pbs-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };
  };
}
