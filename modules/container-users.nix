{
  config,
  lib,
  ...
}:
let
  cfg = config.containerUsers;
in
{
  options.containerUsers = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Lingering system users that own rootless podman containers.";
  };

  config = lib.mkIf (cfg != [ ]) {
    users.manageLingering = true;

    users.users = lib.genAttrs cfg (name: {
      isSystemUser = true;
      group = name;
      linger = true;
      home = "/var/lib/${name}";
      createHome = true;
      autoSubUidGidRange = true;
    });

    users.groups = lib.genAttrs cfg (_: { });
  };
}
