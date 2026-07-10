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
    ./services.nix
    ./k3s/kubes.nix
    ./k3s/uptime-k3s.nix
    ./k3s/headlamp-k3s.nix
    ./networking.nix
    ../../../modules/nixvim.nix
    ../../../modules/virtualization.nix
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
      "borg"
      "libvirtd"
      "kvm"
    ];
  };

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;  

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
    virtualization.enable = true;
  };

}
