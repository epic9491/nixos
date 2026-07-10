{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.newt = {
    enable = true;
    environmentFile = "/run/agenix/newt.env.age";
    settings = {
      endpoint = "https://pangolin.gumbolabs.xyz";
    };
  };
  
  systemd.services.newt.serviceConfig.DynamicUser = lib.mkForce false;
  
  users.users.newt = {
    isSystemUser = true;
    group = "newt";
  };
  
  users.groups.newt = {};
  
  age.secrets."newt.env.age" = {
    file = ../../../secrets/newt.env.age;
    path = "/run/agenix/newt.env.age";
    owner = "newt";
    group = "newt";
    mode = "0400";
  };
}
