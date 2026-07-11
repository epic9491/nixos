{ lib, ... }:
{
  services.cockpit = {
    enable = true;
    openFirewall = false;
    settings.WebService.LoginTo = false;
  };

  systemd.sockets.cockpit = {
    socketConfig.FreeBind = true;
    listenStreams = lib.mkForce [
      ""
      "100.69.69.210:9090"
      "[fd7a:115c:a1e0::7e36:ab2a]:9090"
    ];
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 9090 ];
}
