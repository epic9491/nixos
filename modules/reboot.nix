{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.server.kernelReboot;
in
{
  options.server.kernelReboot.enable = lib.mkEnableOption "nightly reboot if booted kernel != current";

  config = lib.mkIf cfg.enable {
    systemd.services.kernel-reboot = {
      serviceConfig.Type = "oneshot";
      script = ''
        booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules})"
        current="$(readlink /run/current-system/{initrd,kernel,kernel-modules})"
        if [ "$booted" != "$current" ]; then
          ${pkgs.systemd}/bin/shutdown -r +1
        fi
      '';
    };

    systemd.timers.kernel-reboot = {
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "*-*-* 02:00:00";
    };
  };
}
