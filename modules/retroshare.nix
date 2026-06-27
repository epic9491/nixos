{ config, lib, pkgs, ... }:
let
  cfg = config.workstation.retroshare;
in
{
  options.workstation.retroshare.enable =
    lib.mkEnableOption "Syncthing RetroArch share";

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = "gumbo";
      group = "users";
      dataDir = "/home/gumbo/sync";
      configDir = "/home/gumbo/.config/syncthing";
      overrideDevices = false;
      overrideFolders = false;
      openDefaultPorts = true;

      settings = {
        devices = {
          "rom-server" = {
            id = "24SWUHL-ACNDYW3-33VLYSV-XFOJNVJ-YFWUKQE-YNXNZJ2-OABB2XN-NPSAEAD";
          };
        };
        folders = {
          "roms" = {
            id = "gbqcn-diyh4";
            path = "/home/gumbo/roms";
            devices = [ "rom-server" ];
            type = "receiveonly";
          };
          "saves" = {
            id = "fewek-jpwfx";
            path = "/home/gumbo/saves";
            devices = [ "rom-server" ];
            type = "sendreceive";
          };
        };
      };
    };
  };
}
