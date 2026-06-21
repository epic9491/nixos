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
    #./backup.nix
    ../../../modules/ssh.nix
    ../../../modules/baseline.nix
    ../../../modules/packages.nix
  ];

  networking.hostName = "console";

  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;

  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "gumbo";
    };
    defaultSession = "kodi";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
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

  #age.identityPaths = [ "/home/gumbo/.ssh/agenix" ];

  services.xserver.desktopManager.kodi.enable = true;
  services.xserver.desktopManager.kodi.package = pkgs.kodi.withPackages (kp: with kp; [
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

  environment.systemPackages = with pkgs; [
    moonlight-qt
    chromium
    (pkgs.writeShellScriptBin "launch-steam-stream" ''
      exec ${pkgs.moonlight-qt}/bin/moonlight stream Erebos "Steam" --resolution 1920x1080 --fps 60
    '')
    (pkgs.writeShellScriptBin "launch-appletv" ''
      exec ${pkgs.chromium}/bin/chromium --kiosk --app=https://tv.apple.com
    '')
  ];
}
