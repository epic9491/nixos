{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.workstation.kde;
  background-package = pkgs.stdenvNoCC.mkDerivation {
    name = "background-image";
    src = ../pics/nix2.png;
    dontUnpack = true;
    installPhase = ''
      cp $src $out
    '';
  };
in
{
  options.workstation.kde.enable = lib.mkEnableOption "KDE Plasma-based workstation environment";

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };
    services.displayManager.sddm = {
      enable = true;
      theme = "breeze";
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = true;
    services.displayManager.defaultSession = "plasma";
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      konsole
      elisa
      discover
      ark
      kcalc
      gwenview
      khelpcenter
      kate
      ktexteditor
      print-manager
      okular
    ];
    qt = {
      enable = true;
    };
    environment.systemPackages = with pkgs; [
      gnome-themes-extra
      rose-pine-cursor
      (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
        [General]
        background = "${background-package}"
      '')
    ];
  };
}
