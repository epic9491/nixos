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
    ./kubes.nix
  ];

  age.identityPaths = [ "/home/gumbo/.ssh/agenix" ];

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

  networking.hostName = "k3-1";

  server.baseline.enable = true;

  environment.systemPackages = with pkgs; [
    vim
  ];

  workstation = {
    ssh.enable = true;
  };
}

