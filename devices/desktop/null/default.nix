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
    ./networking.nix
    ../../../modules/baseline.nix 
    ../../../modules/kde.nix 
    ../../../modules/packages.nix
    ../../../modules/ssh.nix
    ../../../modules/nixvim.nix
    ../../../modules/yazi.nix
    ../../../modules/flatpak.nix
  ];

  # hostname
  networking.hostName = "null";

  workstation = {
    baseline = {
      enable = true;              
      packages = {
        tools = true;             
        dev = false;              
        apps = false;             
      };
    };      
    nixvim.enable = true;         
    kde.enable = true;           
    yazi.enable = true;           
    ssh.enable = true;            
    flatpak = {
      enable = true;
      onCalendar = "weekly";
      packages = [
        "flathub:app/app.zen_browser.zen//stable"
        "flathub:app/com.github.tchx84.Flatseal//stable"
      ];
    };
  };

  #age.identityPaths = [ "/home/gumbo/.ssh/agenix_gumbo" ];

  fileSystems."/mnt/rip" = {
    device = "/dev/disk/by-uuid/5d53aa1b-a908-4feb-8e8c-956206b63d2d";
    fsType = "ext4";
    options = [
      "nosuid"
      "nodev"
      "noatime"
      "nofail"
    ];
  };

  environment.systemPackages = with pkgs; [
    lm_sensors
    qbittorrent
    calibre
    vesktop
  ];
}
