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
    ./disko.nix
    ./networking.nix
    ./qbittorrent.nix
  ];

  sops.age.sshKeyPaths = [ "/home/gumbo/.ssh/agenix" ];

  users.users.gumbo = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.zsh;
    initialPassword = "supersecretpassword";
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
    ];
  };

  boot.loader.grub.enable = true;

  networking.hostName = "mongoose";

  server.baseline.enable = true;

  services.tailscale.enable = lib.mkForce false;

  ssh.enable = true;
}
