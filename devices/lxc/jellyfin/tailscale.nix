{ pkgs, ... }:
{
  systemd.services.tailscale-serve-jellyfin = {
    description = "Expose Jellyfin via tailscale serve";
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = "${pkgs.tailscale}/bin/tailscale serve --bg --https=443 127.0.0.1:8096";
    };
  };
}
