{
  config,
  pkgs,
  lib,
  ...
}:

let
  nixIconPath = "${config.xdg.dataHome}/icons/nix/nix-icon.svg";
in
{
  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "elementary-xfce";
      package = pkgs.elementary-xfce-icon-theme;
    };
    gtk3.extraConfig.Settings = ''
      gtk-application-prefer-dark-theme=1
    '';
    gtk4.extraConfig.Settings = ''
      gtk-application-prefer-dark-theme=1
    '';
  };

  xdg.dataFile."icons/nix/nix-icon.svg".source = ../config/icons/nix-icon.svg;

  xdg.configFile."xfce4/panel/whiskermenu-12.rc".text = ''
    button-icon=${nixIconPath}
    button-single-row=false
    show-button-title=false
  '';
}
