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

  sops.age.sshKeyPaths = [ "/home/gumbo/.ssh/agenix-master" ];

  environment.sessionVariables.SOPS_AGE_KEY_CMD = "${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i /home/gumbo/.ssh/agenix-master";

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
  server.cd.enable = true;

  boot.initrd.kernelModules = [
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
  ];

  ssh.enable = true;
}
