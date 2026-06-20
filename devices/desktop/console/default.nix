{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./backup.nix
    ../../../modules/ssh.nix
    ../../../modules/baseline.nix
    ../../../modules/packages.nix
  ];

  networking.hostName = "console";

  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "gumbo";
    };
    defaultSession = "kodi";
    lightdm.enable = true;
  };

  workstation = {
    baseline = {
      enable = true;
      packages = {
        dev = false;
        tools = true;
        apps = false;
      };
    };
    ssh.enable = true;
  };

  age.identityPaths = [ "/home/gumbo/.ssh/agenix" ];

  services.xserver.desktopManager.kodi.enable = true;
  services.xserver.desktopManager.kodi.package = pkgs.kodi;

  environment.systemPackages = with pkgs; [
    moonlight-qt
  ]  ++ (with kodiPackages; [
    keymap
    netflix
    jellycon
    youtube
    joystick
    libretro
    libretro-mgba
    steam-library
    bluetooth-manager
  ]);
}
