{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.workstation.baseline.packages;
  future-cursors = pkgs.callPackage ../pkgs/future-cursor.nix { };
  toolsPackages = with pkgs; [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    yubikey-manager
    wget
    git
    htop
    curl
    tree
    eza
    ghostty
    fastfetch
    starship
    lazyssh
    nixfmt
    blueman
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
    screen
    speedtest
    unzip
    parallel
    future-cursors
  ];

  devPackages = with pkgs; [
    rustup
    cargo
    gcc
    rustlings
    terraform
    distrobox
  ];

  appsPackages = with pkgs; [
    yubioath-flutter
    (retroarch.withCores (cores: with cores; [ mgba ]))
    vlc
    libreoffice
    gimp
    feishin
    picard
    jellyfin-desktop
    gnome-calculator
  ];
in
{
  options.workstation.baseline.packages = {
    tools = lib.mkEnableOption "CLI tools and utilities";
    dev = lib.mkEnableOption "Development tools";
    apps = lib.mkEnableOption "Desktop applications";
  };

  config = {
    environment.systemPackages =
      (lib.optionals cfg.tools toolsPackages)
      ++ (lib.optionals cfg.dev devPackages)
      ++ (lib.optionals cfg.apps appsPackages);
  };
}
