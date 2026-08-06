{ lib, ... }:
let
  containerUsers = [
    "traefik"
    "anubis"
    "searxng"
    "privatebin"
    "crowdsec"
    "tuwunel"
    "outage"
    "wiki"
    "webfinger"
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
      "traefik"
      "crowdsec"
    ];
  };
}
