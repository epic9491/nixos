{
  users.manageLingering = true;

  users.users.mealie = {
    isSystemUser = true;
    group = "mealie";
    linger = true;
    home = "/var/lib/mealie";
    createHome = true;
    subUidRanges = [ { startUid = 100000; count = 65536; } ];
    subGidRanges = [ { startGid = 100000; count = 65536; } ];
  };
  users.groups.mealie = { };

  users.users.newt = {
    isSystemUser = true;
    group = "newt";
    linger = true;
    home = "/var/lib/newt";
    createHome = true;
    subUidRanges = [ { startUid = 165536; count = 65536; } ];
    subGidRanges = [ { startGid = 165536; count = 65536; } ];
  };
  users.groups.newt = { };
}
