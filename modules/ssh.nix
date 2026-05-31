{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.workstation.ssh;
in
{
  options.workstation.ssh.enable = lib.mkEnableOption "Default SSH configuration";
  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "gumbo" ];
      };
    };
    users.users."gumbo".openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHUkxCvottvNhhfO11kxxfDBlKL/6+3j3wU00BPKGkljAAAABHNzaDo= yubikey1"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPASaOPqKbg2qWBPScJdLt7Um+npdx4XAg8qB7GAA4yaAAAABHNzaDo= yubikey 2 thinkpad"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIL6UrcHX2dRQu98j1yAO2Xo+XOJReQEXHuYIukguk8/aAAAABHNzaDo= yubikey3 mobile"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMHAg8btMUyPygL6n7d+aPu9surWfKncWrRf5o1pFRsxAAAABHNzaDo= yubikey4 backup"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICnfZ1F0i8Jeid2KZ0EZZWlD9yX8lDLZFyHf6NfWZZ4O ansible@ansible"
    ];
    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}
