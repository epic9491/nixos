{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../../../modules/nixvim.nix
  ];

  age.identityPaths = [ "/home/gumbo/.ssh/agenix-master" ];

  users.users.gumbo = {
    isNormalUser = true;
    shell = pkgs.zsh;
    initialPassword = "supersecretpassword";
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
      "sound"
      "video"
      "audio"
    ];
  };

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  networking.hostName = "secret-mgmt";

  server.baseline.enable = true;

  workstation = {
    ssh.enable = true;
    nixvim.enable = true;
  };
}

