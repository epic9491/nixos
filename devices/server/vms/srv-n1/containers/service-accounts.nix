{ lib, ... }:
let
  containerUsers = [ "mealie" "newt" ]; # add new services here, nothing else to touch
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

  users.groups = lib.genAttrs containerUsers (_: { });
}
