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
    in
    {
      home.stateVersion = "25.05";

      services.podman = {
        enable = true;

        containers.tuwunel = {
          image = "ghcr.io/matrix-construct/tuwunel:v1.8.2@sha256:6f950bb139411a7964781e986321e395e045e4a6a52240a4dda9d23d04075f78";
          autoStart = true;
          ports = [ "127.0.0.1:8086:8008" ];
          volumes = [
            "/var/lib/tuwunel/db:/var/lib/tuwunel"
            "${config}:/etc/tuwunel/tuwunel.toml:ro"
          ];
          environment.TUWUNEL_CONFIG = "/etc/tuwunel/tuwunel.toml";
          environmentFile = [ "/run/secrets/tuwunel.env" ];
          extraConfig = {
            Container = {
              DropCapability = "ALL";
              NoNewPrivileges = true;
              ReadOnly = true;
              Tmpfs = "/tmp";
            };
            Service.Restart = "always";
          };
        };
      };
    };

  sops.secrets."tuwunel.env" = {
    sopsFile = ../../../../secrets/srv-n2.tuwunel.env;
    format = "binary";
    owner = "tuwunel";
    group = "tuwunel";
    mode = "0400";
  };
}
