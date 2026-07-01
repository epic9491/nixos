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
    # ./backup.nix
  ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  users.users.gumbo = {
    isNormalUser = true;
    shell = pkgs.zsh;
    initialPassword = "supersecretpassword";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  age.identityPaths = [ "/home/gumbo/.ssh/agenix" ];

  networking.hostName = "srv-n1";

  server.baseline.enable = true;
  workstation = {
    ssh.enable = true;
  };
}
