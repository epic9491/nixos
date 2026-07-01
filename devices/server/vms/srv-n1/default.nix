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
    inputs.lanzaboote.nixosModules.lanzaboote
    # ./backup.nix
  ];

  environment.systemPackages = [ pkgs.sbctl ];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = lib.mkForce false;
        configurationLimit = 8;
      };
    };
    initrd.systemd.enable = true;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        autoReboot = true;
      };
      measuredBoot = {
        enable = true;
        pcrs = [
          0
          4
          7
        ];
      };
    };
  };

  users.users.gumbo = {
    isNormalUser = true;
    shell = pkgs.zsh;
    initialPassword = "supersecretpassword";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  age.identityPaths = [ "/home/gumbo/.ssh/agenix" ];

  networking.hostName = "srv-n1";

  server.baseline.enable = true;
  workstation = {
    ssh.enable = true;
  };
}
