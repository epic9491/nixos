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
    ./backup.nix
    ./containers
  ];

  boot.loader.grub.enable = true;

  boot.kernelModules = [
    "wireguard"
    "tun"
  ];

  users.users.gumbo = {
    isNormalUser = true;
    shell = pkgs.zsh;
    initialPassword = "supersecretpassword";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  networking = {
    hostName = "pangolin";
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
    kernelReboot.enable = true;
  };
  ssh = {
    enable = true;
    port = 420;
  };
}
