{ pkgs, ... }:
{
  services.tailscale.permitCertUid = "root";

  systemd.services.tailscale-serve-jellyfin = {
    description = "Expose Jellyfin via tailscale serve";
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
    bindsTo = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.tailscale}/bin/tailscale serve --bg --https=443 localhost:8096";
      ExecStop = "${pkgs.tailscale}/bin/tailscale serve --https=443 off";
    };
  };
}
