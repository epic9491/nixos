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
      remotes = [
        {
          name = "origin";
          url = "https://git.zorse-ruffe.ts.net/sensei/nixos.git";
          branches.main.name = "deploy";
        }
      ];
    };
  };
}
