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
    "${modulesPath}/virtualisation/proxmox-lxc.nix"
  ];

  proxmoxLXC = {
    enable = true;
    manageNetwork = false;
    manageHostName = true;
  };

  age.identityPaths = [ "/home/gumbo/.ssh/agenix" ];

  users.users.gumbo = {
    isNormalUser = true;
    shell = pkgs.zsh;
    initialPassword = "supersecretpassword";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  networking.hostName = "lxc-n1";

  server.baseline.enable = true;

  services.qemuGuest.enable = lib.mkForce false;
  networking.networkmanager.enable = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    vim
  ];

  ssh.enable = true;
}
