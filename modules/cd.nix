{
  config,
  lib,
  pkgs,
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
      # only my security key and instance get root via comin
      sshAllowedSignersPath = toString (
        pkgs.writeText "comin-allowed-signers" ''
          sensei namespaces="git" sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPASaOPqKbg2qWBPScJdLt7Um+npdx4XAg8qB7GAA4yaAAAABHNzaDo=
          forgejo-instance namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOUQFtzV+oQ/lKEzntgqo6DIxH40V6dcnTG0+NWBxqBi
        ''
      );
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
