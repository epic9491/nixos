{ lib, ... }:
let
  containerUsers = [
    "caddy"
    "searxng"
    "privatebin"
    "crowdsec"
  ];
in
{
  users.manageLingering = true;

  users.users = lib.genAttrs containerUsers (name: {
    isSystemUser = true;
    group = name;
    linger = true;
    home = "/var/lib/${name}";
    createHome = true;
    autoSubUidGidRange = true;
  });

  users.groups = lib.genAttrs containerUsers (_: { }) // {
    weblogs.members = [
      "caddy"
      "crowdsec"
    ];
  };
}
