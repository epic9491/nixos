{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.workstation.hypr;
in
{
  options.workstation.hypr.enable = lib.mkEnableOption "Hyprland-based workstation environment";

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd 'uwsm start hyprland-uwsm.desktop'";
          user = "greeter";
        };
        initial_session = {
          command = "uwsm start hyprland-uwsm.desktop";
          user = "gumbo";
        };
      };
    };

    programs.hyprlock.enable = true;
    security.pam.services.hyprlock = { };

    environment.systemPackages = with pkgs; [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      hyprpaper
      fuzzel
      gnome-themes-extra
      brightnessctl
      pamixer
      grim
      slurp
      wl-clipboard
      swayimg
      nemo
      gvfs
    ];
  };
}
