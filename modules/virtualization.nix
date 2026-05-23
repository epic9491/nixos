{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.workstation.virtualization;
in
{
  options.workstation.virtualization.enable = lib.mkEnableOption "Enable virtualization support for libvirt qemu/kvm";

  config = lib.mkIf cfg.enable {

    programs.virt-manager.enable = true;
    virtualisation = {
      libvirtd = {
        enable = true;
        allowedBridges = [ "virbr0" "br0" ];
        qemu.swtpm.enable = true;
      };
      spiceUSBRedirection.enable = true;
    };

    services = {
      qemuGuest.enable = true;
      spice-vdagentd.enable = true;
    };
  };
}
