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
    ./backup.nix
    inputs.lanzaboote.nixosModules.lanzaboote
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
    initrd = {
      systemd = {
        enable = true;
        emergencyAccess = true;
      };
      luks.devices."cryptroot" = {
        keyFile = lib.mkForce null;
        crypttabExtraOpts = [ "tpm2-device=auto" ];
      };
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys.enable = true;
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
