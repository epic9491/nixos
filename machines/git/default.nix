{
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    ./hardware-configuration.nix
    ./disko.nix
    ./backup.nix
    ./tailscale.nix
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

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  networking = {
    hostName = "git";
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
