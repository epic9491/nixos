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
    ./kubes.nix
    ./charts/headlamp.nix
    ./charts/uptime.nix
    ./charts/newt.nix
    ./charts/grafana.nix
    ./charts/influxdb.nix
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
    ];
  };

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  networking.hostName = "k3s-s1";
  networking.firewall.backend = "iptables";

  # Physical host — disable the QEMU guest agent enabled by baseline.server

  server.baseline.enable = true;

  workstation = {
    ssh.enable = true;
  };

}
