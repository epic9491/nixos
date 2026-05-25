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
    ../../../../modules/baseline.nix
    ../../../../modules/kde.nix
    ../../../../modules/packages.nix
    ../../../../modules/ssh.nix
    ../../../../modules/flatpak.nix
  ];

  # hostname
  networking.hostName = "seed";

  workstation = {
    baseline = {
      enable = true;
      packages = {
        tools = true;
        dev = false;
        apps = false;
      };
    };
    kde.enable = true;
    ssh.enable = true;
    flatpak = {
      enable = true;
      onCalendar = "weekly";
      packages = [
        "flathub:app/app.zen_browser.zen//stable"
      ];
    };
  };

  age.identityPaths = [ "/home/gumbo/.ssh/agenix" ];

  environment.systemPackages = with pkgs; [
    vim 
    qbittorrent
  ];
}
