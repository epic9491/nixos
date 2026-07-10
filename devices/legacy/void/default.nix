{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../../modules/nixvim.nix
    ./tuwunel.nix
    ./firewall.nix
    ./backup.nix
  ];

  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];
  };

  users.users.gumbo = {
    isNormalUser = true;
    shell = pkgs.zsh;
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

  age.identityPaths = [ "/home/gumbo/.ssh/id_ed25519" ];

  networking.hostName = "void";

  server.baseline.enable = true;
  workstation = {
    ssh.enable = true;
    nixvim.enable = true;
  };
}
