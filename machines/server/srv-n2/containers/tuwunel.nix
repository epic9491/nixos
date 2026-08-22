{
  home-manager.users.tuwunel =
    { pkgs, ... }:
    let
      config = pkgs.writeText "tuwunel.toml" ''
        [global]
        address = ["0.0.0.0", "::"]
        port = 8008
        database_path = "/var/lib/tuwunel"

        allow_registration = false
        grant_admin_to_first_user = true
        new_user_displayname_suffix = ""

        allow_federation = true
        allow_public_room_directory_over_federation = false
        allow_public_room_directory_without_auth = false
        allow_device_name_federation = false

        max_request_size = "100 MiB"
      '';

      image = "ghcr.io/matrix-construct/tuwunel:v1.9.0@sha256:295a1ceedbfd7afce05c69a38efb246dd31fa810e5d352fc7a09b261853800ee";

      hardening = {
        Container = {
          DropCapability = "ALL";
          NoNewPrivileges = true;
          ReadOnly = true;
          Tmpfs = "/tmp";
        };
        Service.Restart = "always";
      };
    in
    {
      home.stateVersion = "25.05";

      services.podman = {
        enable = true;

        containers.tuwunel = {
          inherit image;
          autoStart = true;
          ports = [ "127.0.0.1:8086:8008" ];
          volumes = [
            "/var/lib/tuwunel/db:/var/lib/tuwunel"
            "${config}:/etc/tuwunel/tuwunel.toml:ro"
          ];
          environment.TUWUNEL_CONFIG = "/etc/tuwunel/tuwunel.toml";
          environmentFile = [ "/run/secrets/tuwunel.env" ];
          extraConfig = hardening;
        };

        # server_name cant change on an existing db, so goc.dev is a second instance
        containers.tuwunel-goc = {
          inherit image;
          autoStart = true;
          ports = [ "127.0.0.1:8091:8008" ];
          volumes = [
            "/var/lib/tuwunel/db-goc:/var/lib/tuwunel"
            "${config}:/etc/tuwunel/tuwunel.toml:ro"
          ];
          environment.TUWUNEL_CONFIG = "/etc/tuwunel/tuwunel.toml";
          environmentFile = [ "/run/secrets/tuwunel-goc.env" ];
          extraConfig = hardening;
        };
      };
    };

  sops.secrets = {
    "tuwunel.env" = {
      sopsFile = ../../../../secrets/srv-n2.tuwunel.env;
      format = "binary";
      owner = "tuwunel";
      group = "tuwunel";
      mode = "0400";
    };
    "tuwunel-goc.env" = {
      sopsFile = ../../../../secrets/srv-n2.tuwunel-goc.env;
      format = "binary";
      owner = "tuwunel";
      group = "tuwunel";
      mode = "0400";
    };
  };
}
