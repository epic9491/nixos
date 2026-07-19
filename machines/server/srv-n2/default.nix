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
    initialPassword = "supersecretpassword";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  sops.age.sshKeyPaths = [ "/home/gumbo/.ssh/agenix" ];

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

  systemd.targets.network-online.wantedBy = [ "multi-user.target" ];

  server.baseline.enable = true;
  server.cd.enable = true;
  ssh = {
    enable = true;
    port = 42069;
  };
}
