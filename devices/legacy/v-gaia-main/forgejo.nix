{ config, ... }:

{

  users = {
    groups.forgejo.gid = 990;
    users.forgejo = {
      isSystemUser = true;
      group = "forgejo";
      uid = 990;
    };
  };

  containers.forgejo = {
    autoStart = true;
    bindMounts."/run/secrets/forgejo_dbPass" = {
      hostPath = "/run/agenix/forgejo_dbPass.age";
      isReadOnly = true;
    };
    config = { config, pkgs, ... }: {
      system.stateVersion = "25.11";
      users = {
        groups.forgejo.gid = 990;
        users.forgejo.uid = 990;
      };
      services.forgejo = {
        package = pkgs.forgejo;
        enable = true;
        database = {
          type = "postgres";
          createDatabase = false;
          host = "127.0.0.1";
          port = 5432;
          name = "forgejo";
          user = "gumbo";
          passwordFile = "/run/secrets/forgejo_dbPass";
        };
        settings = {
          session.COOKIE_SECURE = true;
          server = {
            PROTOCOL = "http";
            HTTP_ADDR = "127.0.0.1";
            HTTP_PORT = 3000;
            SSH_PORT = 222;
            DOMAIN = "git.gumbolabs.xyz";
            ROOT_URL = "https://git.gumbolabs.xyz/";
          };
        };
      };
    };
  };
  
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "forgejo" ];
    ensureUsers = [{
      name = "gumbo";
    }];
    authentication = ''
      host forgejo gumbo 127.0.0.1/32 md5
    '';
  };

  age.secrets."forgejo_dbPass.age" = {
    file = ../../../secrets/forgejo_dbPass.age;
    path = "/run/agenix/forgejo_dbPass.age";
    owner = "forgejo";
    group = "forgejo";
    mode = "0400";
  };
}
