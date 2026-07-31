{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.workstation.xfce;
in
{
  options.workstation.xfce.enable = lib.mkEnableOption "XFCE-based workstation environment";

  config = lib.mkIf cfg.enable {
    programs.nm-applet.enable = true;

    environment.systemPackages = with pkgs; [
      xfce.xfce4-whiskermenu-plugin
      xfce.xfce4-pulseaudio-plugin
      xfce.xfce4-cpugraph-plugin
      xfce.xfce4-battery-plugin
      lightdm-gtk-greeter
      elementary-xfce-icon-theme
    ];

    xserver = {
      enable = true;
      desktopManager.xfce.enable = true;

      displayManager.lightdm = {
        enable = true;
        greeters.gtk = {
          enable = true;
          theme = {
            name = "Adwaita-dark";
            package = pkgs.gnome-themes-extra;
          };
          extraConfig = ''
            default-user-image=/usr/share/pixmaps/gumbo-face.png
          '';
        };
      };
    };

    # displayManager.defaultSession = "xfce";

    services.picom = {
      enable = true;
      fade = true;
      inactiveOpacity = 0.7;
      shadow = true;
      fadeDelta = 4;
      backend = "glx";
      vSync = true;
    };
  };
}
