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
    "${modulesPath}/profiles/qemu-guest.nix"
    ./hardware-configuration.nix
    ./kubes.nix
    ./disko.nix
    ../../../../modules/k3s-agent.nix
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

  boot.loader.grub.enable = true;

  networking.hostName = "k3s-a1";

  server.baseline.enable = true;

  environment.systemPackages = with pkgs; [
    vim
  ];

  workstation = {
    ssh.enable = true;
  };
}

