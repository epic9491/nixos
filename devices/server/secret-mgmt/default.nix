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
    ./disko.nix
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

  boot.initrd.kernelModules = [ "virtio_pci" "virtio_scsi" "sd_mod" ];

  workstation = {
    ssh.enable = true;
  };
}

