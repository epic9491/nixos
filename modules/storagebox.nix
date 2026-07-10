{
  config,
  lib,
  pkgs,
  ...
}:
let
  types = lib.types;
  cfg = config.mount.storagebox;
in
{
  options.mount.storagebox = {
    enable = lib.mkEnableOption "Hetzner Storage Box CIFS mount";

    mountPoint = lib.mkOption {
      type = types.str;
      default = "/mnt/storagebox";
      description = "Where to mount the Storage Box.";
    };

    userId = lib.mkOption {
      type = types.int;
      default = 1000;
      description = "UID owning files on the mount.";
    };

    groupId = lib.mkOption {
      type = types.int;
      default = 100;
      description = "GID owning files on the mount.";
    };

    # main account
    host = lib.mkOption {
      type = types.str;
      default = "u533956.your-storagebox.de";
      description = "Storage Box CIFS host.";
    };

    share = lib.mkOption {
      type = types.str;
      default = "backup";
      description = "Main user on storagebox.";
    };

    credentialsFile = lib.mkOption {
      type = types.str;
      default = "/etc/nixos/smb-secrets";
      description = "Path to CIFS credentials file.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.cifs-utils ];

    # load cifs and apply hetzner tuning
    boot.kernelModules = [ "cifs" ];

    systemd.services.cifs-tune = {
      description = "Hetzner CIFS tuning";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          ${pkgs.kmod}/bin/modprobe cifs
          echo 0 > /proc/fs/cifs/OplockEnabled || true
        '';
      };
    };

    fileSystems.${cfg.mountPoint} = {
      device = "//${cfg.host}/${cfg.share}";
      fsType = "cifs";
      options =
        let
          automount_opts =
            "x-systemd.automount,noauto,x-systemd.idle-timeout=60,"
            + "x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
        in
        [
          "${automount_opts},credentials=${cfg.credentialsFile},uid=${toString cfg.userId},gid=${toString cfg.groupId},iocharset=utf8,rw,seal,file_mode=0660,dir_mode=0770"
        ];
    };
  };
}
