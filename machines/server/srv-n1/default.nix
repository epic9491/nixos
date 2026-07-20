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
    ./hardware-configuration.nix
    ./disko.nix
    ./backup.nix
    ./boot.nix
    ./cockpit.nix
    ./containers
    ./mounts.nix
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 20;
  };
  users.users.gumbo = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  networking = {
    hostName = "srv-n1";
    nameservers = [
      "9.9.9.9"
      "1.1.1.1"
    ];
    networkmanager = {
      dns = "none";
      settings.main.rc-manager = "unmanaged";
    };
  };

  server = {
    baseline.enable = true;
    cd.enable = true;
    cache.enable = true;
  };
  ssh.enable = true;
}
