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
    ./containers
    ./tailscale.nix
  ];

  proxmoxLXC = {
    enable = true;
    manageNetwork = false;
    manageHostName = true;
  };

  sops.age.sshKeyPaths = [ "/home/gumbo/.ssh/agenix" ];

  users.users.gumbo = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  networking.hostName = "jellyfin";

  server.baseline.enable = true;
  server.cd.enable = true;

  services.qemuGuest.enable = lib.mkForce false;
  networking.networkmanager.enable = lib.mkForce false;

  systemd.targets.network-online.wantedBy = [ "multi-user.target" ];

  environment.systemPackages = with pkgs; [
    vim
  ];

  ssh.enable = true;
}
