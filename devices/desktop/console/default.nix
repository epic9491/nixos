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
    ../../../modules/kde.nix
  ];

  networking.hostName = "console";

  hardware.enableRedistributableFirmware = true;

  hardware.xpadneo.enable = true; 

  boot.extraModprobeConfig = '' options bluetooth disable_ertm=1 '';

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "gumbo";
    defaultSession = "plasma";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  workstation = {
    baseline = {
      enable = true;
      packages = {
        dev = false;
        tools = true;
        apps = true;
      };
    };
    ssh.enable = true;
    kde.enable = true;
  };

  #age.identityPaths = [ "/home/gumbo/.ssh/agenix" ];

  environment.systemPackages = with pkgs; [
    moonlight-qt
    (chromium.override { enableWideVine = true; })
  ];
}
