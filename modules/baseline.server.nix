{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.server.baseline;
in
{
  options.server.baseline.enable = lib.mkEnableOption "Baseline server configuration";

  config = lib.mkIf cfg.enable {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    nixpkgs.config.allowUnfree = true;

    networking.networkmanager.enable = true;

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    nix.optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    services.journald.extraConfig = ''
      SystemMaxUse=500M
    '';

    time.timeZone = "America/Chicago";

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

    programs.zsh.enable = true;
    environment.pathsToLink = [ "/share/zsh" ];

    environment.systemPackages = with pkgs; [
      # tools/etc
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      wget
      git
      htop
      curl
      tree
      fastfetch
      starship
      ffmpeg
      whois
      parted
      usbutils
      smartmontools
      pciutils
      file
      dig
      oh-my-zsh
      autojump
      compose2nix
      jq
      screen
      eza
      vim
    ];

    services = {
      tailscale.enable = true;
      qemuGuest.enable = true;
    };

    virtualisation.docker = {
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    system.stateVersion = "25.05";
  };
}
