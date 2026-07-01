{
  users.manageLingering = true;

  users.users.mealie = {
    isSystemUser = true;
    group = "mealie";
    linger = true;
    home = "/var/lib/mealie";
    createHome = true;
  };
  users.groups.mealie = { };

  users.users.newt = {
    isSystemUser = true;
    group = "newt";
    linger = true;
    home = "/var/lib/newt";
    createHome = true;
  };
  users.groups.newt = { };
}
