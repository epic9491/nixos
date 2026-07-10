{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.kavita = {
    enable = true;
    user = "kavita";
    tokenKeyFile = "/run/agenix/kavita.tokenkey.age";
    dataDir = "/var/lib/kavita";
  };

  age.secrets."kavita.tokenkey.age" = {
    file = ../../../secrets/kavita.tokenkey.age;
    path = "/run/agenix/kavita.tokenkey.age";
    owner = "kavita";
    group = "users";
    mode = "0400";
  };

  fileSystems."/mnt/manga" = {
    device = "192.168.0.183:/mnt/jelly/manga";
    fsType = "nfs";
    options = [
      "noatime"
      "nofail"
    ];
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 5000 ];
  };
}
