{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.workstation.gnome;
in
{
  options.workstation.gnome.enable = lib.mkEnableOption "GNOME-based workstation environment";

  config = lib.mkIf cfg.enable {
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    services.gnome.core-apps.enable = false;
    services.gnome.core-developer-tools.enable = false;
    services.gnome.games.enable = false;
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-user-docs
    ];
    services.sysprof.enable = true;

    environment.systemPackages = with pkgs; [
      gnome-themes-extra
      papirus-icon-theme
      rose-pine-cursor
      gnomeExtensions.blur-my-shell
      gnomeExtensions.vitals
      gnomeExtensions.user-themes
      gnomeExtensions.dash-to-dock
      gnomeExtensions.appindicator
      gnome-tweaks
    ];

    programs.dconf.profiles.user.databases = [
      {
        settings = {
          "org/gnome/mutter" = {
            experimental-features = [
              "scale-monitor-framebuffer"
              "variable-refresh-rate"
              "xwayland-native-scaling"
              "autoclose-xwayland"
            ];
          };
        };
      }
    ];
  };
}
