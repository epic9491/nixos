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
    ./wazuh.nix
    inputs.aliased.nixosModules.aliased
  ];

  nixpkgs.overlays = [ inputs.aliased.overlays.default ];

  boot.loader.grub.enable = true;

  users.users.gumbo = {
    isNormalUser = true;
    shell = pkgs.zsh;
    initialPassword = "supersecretpassword";
    extraGroups = [ "wheel" ];
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  networking.hostName = "aliased";
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

  services.aliased = {
    enable = true;
    domain = "aliased.lol";
    acmeEmail = "acme@aliased.lol";
    tailnetAddress = "100.69.69.50";
  };

  sops.secrets."aliased.addy.env" = {
    sopsFile = ../../../secrets/aliased.addy.env;
    format = "binary";
    owner = "addy";
    group = "addy";
    mode = "0400";
  };
  sops.secrets."aliased.db.env" = {
    sopsFile = ../../../secrets/aliased.db.env;
    format = "binary";
    owner = "addy";
    group = "addy";
    mode = "0400";
  };
  sops.secrets."aliased.redis.conf" = {
    sopsFile = ../../../secrets/aliased.redis.conf;
    format = "binary";
    owner = "addy";
    group = "addy";
    mode = "0400";
  };
}
