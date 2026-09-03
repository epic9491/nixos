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
    ./containers
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # opensearch mmaps every shard and refuses to start under the default 65530
  boot.kernel.sysctl."vm.max_map_count" = 262144;

  # the manager wants 655360 fds, above systemds 524288 default hard cap
  systemd.settings.Manager.DefaultLimitNOFILE = "1024:1048576";

  users.users.gumbo = {
    isNormalUser = true;
    shell = pkgs.zsh;
    initialPassword = "supersecretpassword";
    extraGroups = [
      "wheel"
    ];
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  networking.hostName = "wazuh";

  systemd.targets.network-online.wantedBy = [ "multi-user.target" ];

  # bare metal, theres no host to answer the guest agent
  services.qemuGuest.enable = lib.mkForce false;

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
