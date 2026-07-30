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
    ./networking.nix
    ./backup.nix
    ./containers
  ];

  boot.loader.grub.enable = true;

  users.users.gumbo = {
    isNormalUser = true;
    shell = pkgs.zsh;
    initialPassword = "supersecretpassword";
    extraGroups = [
      "wheel"
    ];
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  networking.hostName = "srv-n2";

  systemd.targets.network-online.wantedBy = [ "multi-user.target" ];

  server = {
    baseline.enable = true;
    cd.enable = true;
    kernelReboot.enable = true;
  };

  ssh = {
    enable = true;
    port = 42069;
  };
}
