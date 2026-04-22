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
    ../../../modules/nixvim.nix
  ];

  age.identityPaths = [ "/home/gumbo/.ssh/id_ed25519" ];

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
      "borg"
    ];
  };

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  networking.hostName = "zeus";

  # Physical host — disable the QEMU guest agent enabled by baseline.server
  services.qemuGuest.enable = lib.mkForce false;

  server.baseline.enable = true;

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/78385fc9-6578-4560-b235-c28bcddc0c46";
    fsType = "ext4";
    options = [
      "nosuid"
      "nodev"
      "noatime"
      "nofail"
    ];
  };

  workstation = {
    ssh.enable = true;
    nixvim.enable = true;
  };
}
