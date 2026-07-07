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
    ../../../modules/flatpak.nix
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

  services.displayManager.autoLogin = {
    enable = true;
    user = "gumbo";
  };

  services.sunshine = {
    enable = true;
    capSysAdmin = true;
  };

  networking.firewall.interfaces = {
    ens18 = {
      allowedTCPPorts = [
        47984
        47989
        47990
        48010
      ];
      allowedUDPPorts = [
        47998
        47999
        48000
        48002
        48010
      ];
    };
    tailscale0 = {
      allowedTCPPorts = [
        47984
        47989
        47990
        48010
      ];
      allowedUDPPorts = [
        47998
        47999
        48000
        48002
        48010
      ];
    };
  };

  age.identityPaths = [ "/home/gumbo/.ssh/agenix" ];

  environment.systemPackages = with pkgs; [
    vim 
    qbittorrent
  ];
}
