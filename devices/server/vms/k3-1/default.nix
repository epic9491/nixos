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
    ./disko.nix
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
    ];
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
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

