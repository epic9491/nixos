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
    "${modulesPath}/profiles/qemu-guest.nix"
    ./hardware-configuration.nix
    ./disko.nix
    ./containers
  ];

  boot.loader.grub.enable = true;

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
    hostName = "srv-n2";
    nameservers = [
      "9.9.9.9"
      "1.1.1.1"
    ];
    networkmanager = {
      dns = "none";
      settings.main.rc-manager = "unmanaged";
    };
  };

  server.baseline.enable = true;
  server.cd.enable = true;
  ssh.enable = true;
}
