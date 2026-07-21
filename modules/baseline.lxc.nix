{
  lib,
  pkgs,
  modulesPath,
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

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  users.users.gumbo = {
    isNormalUser = true;
    initialPassword = "supersecretpassword";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  server.baseline.enable = lib.mkDefault true;
  server.cd.enable = lib.mkDefault true;
  ssh.enable = lib.mkDefault true;

  services.qemuGuest.enable = lib.mkForce false;
  networking.networkmanager.enable = lib.mkForce false;
  server.dns.enable = lib.mkForce false;

  systemd.targets.network-online.wantedBy = [ "multi-user.target" ];
}
