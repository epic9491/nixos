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
}
