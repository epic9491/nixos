{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.server.cd;
in
{
  imports = [ inputs.comin.nixosModules.comin ];

  options.server.cd.enable = lib.mkEnableOption "comin GitOps continuous deployment";

  config = lib.mkIf cfg.enable {
    services.comin = {
      enable = true;
      exporter.listen_address = "127.0.0.1";
      remotes = [
        {
          name = "origin";
          url = "https://git.zorse-ruffe.ts.net/sensei/nixos.git";
          branches.main.name = "deploy";
          # empty name disables the ungated testing-<host> branch
          branches.testing.name = "";
        }
      ];
    };

    # comin chmods grpc.sock to 0777, lock the dir instead
    systemd.tmpfiles.rules = [ "d /var/lib/comin 0700 root root -" ];
  };
}
