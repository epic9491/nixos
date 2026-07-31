{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.workstation.niri;
in
{
  options.workstation.niri.enable = lib.mkEnableOption "Niri-based workstation environment with Noctalia Shell";

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;

    qt = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      xwayland-satellite
      gnome-themes-extra
      swayimg
      rose-pine-cursor
      papirus-icon-theme
      nemo
      fuzzel
      gpu-screen-recorder
      wl-clipboard
      libsForQt5.qt5ct
      mpvpaper
    ];

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --cmd niri-session";
          user = "greeter";
        };

        initial_session = {
          command = "niri-session";
          user = "gumbo";
        };
      };
    };
  };
}
