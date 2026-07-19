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
    ./chromium.nix
    ../../../modules/ssh.nix
    ../../../modules/baseline.nix
    ../../../modules/packages.nix
    ../../../modules/kde.nix
    ../../../modules/retroshare.nix
  ];

  networking.hostName = "console";

  hardware.enableRedistributableFirmware = true;

  hardware.xpadneo.enable = true;

  boot.extraModprobeConfig = "options bluetooth disable_ertm=1 ";

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "gumbo";
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
    kde.enable = true;
    retroshare.enable = true;
  };

  ssh.enable = true;

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  environment.systemPackages = with pkgs; [
    moonlight-qt
    python3
  ];
}
