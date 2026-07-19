{ pkgs, ... }:
{
  services.tailscale.openFirewall = true;

  systemd.services.tailscale-serve-forgejo = {
    description = "Expose Forgejo via tailscale serve";
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = "${pkgs.tailscale}/bin/tailscale serve --bg --https=443 http://127.0.0.1:3000";
    };
  };

  systemd.services.tailscale-serve-forgejo-ssh = {
    description = "Expose Forgejo git SSH via tailscale serve";
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = "${pkgs.tailscale}/bin/tailscale serve --bg --tcp=22 tcp://127.0.0.1:2222";
    };
  };
}
