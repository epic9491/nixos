{
  config,
  lib,
  pkgs,
  ...
}:
{
  networking.wg-quick = {
    interfaces = {
      wg0 = {
        autostart = true;
        configFile = "/run/secrets/wg0.conf";
      };
    };
  };
  environment.systemPackages = with pkgs; [
    libnatpmp
  ];
  age.secrets."wg0.age" = {
    file = ../../../secrets/wg0.age;
    path = "/run/secrets/wg0.conf";
    owner = "gumbo";
    group = "users";
    mode = "0400";
  };
}
