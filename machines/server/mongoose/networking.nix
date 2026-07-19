{ pkgs, ... }:
{
  networking.wg-quick.interfaces.wg0 = {
    autostart = true;
    configFile = "/run/secrets/wg0.conf";
  };

  environment.systemPackages = with pkgs; [
    libnatpmp
  ];

  sops.secrets."wg0.conf" = {
    sopsFile = ../../../secrets/wg0;
    format = "binary";
    owner = "gumbo";
    group = "users";
    mode = "0400";
  };

  networking.firewall.interfaces.ens18.allowedTCPPorts = [ 8080 ];
}
