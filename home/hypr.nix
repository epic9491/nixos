{
  config,
  pkgs,
  lib,
  ...
}:

{

  xdg.configFile."hypr" = {
    source = ../config/hypr;
    recursive = true;
  };

  xdg.configFile."waybar" = {
    source = ../config/waybar;
    recursive = true;
  };

  xdg.dataFile."icons/future-cyan" = {
    source = ../config/icons/future-cyan;
    recursive = true;
  };

  gtk = {
    enable = true;

    theme = {
      name = "Graphite-Dark";
      package = pkgs.graphite-gtk-theme;
    };

    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };

    gtk3.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
    };

    gtk4.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Graphite-Dark";
      icon-theme = "Papirus";
    };
  };

  programs.obs-studio = {
    enable = true;

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-vaapi
      obs-gstreamer
      obs-vkcapture
    ];
  };

}
