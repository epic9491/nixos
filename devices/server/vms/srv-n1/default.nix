{
  config,
  lib,
  pkgs,
  inputs,
  modulesPath,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./backup.nix
    ./boot.nix
    ./containers
    ./mounts.nix
  ];

  users.users.gumbo = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  age.identityPaths = [ "/home/gumbo/.ssh/agenix" ];

  networking = {
    hostName = "srv-n1";
    nameservers = [ "9.9.9.9" "1.1.1.1" ];
    networkmanager = {
      dns = "none";
      settings.main.rc-manager = "unmanaged";
    };
  };

  server.baseline.enable = true;
  workstation = {
    ssh.enable = true;
  };
}
