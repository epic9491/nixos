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
    ];
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  networking.hostName = "pangolin";

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
