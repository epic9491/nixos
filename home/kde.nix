{
  config,
  pkgs,
  lib,
  ...
}:

{
  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
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

  xdg.configFile = {
    "ghostty/config".source = ../config/ghostty/tokyo-night.kde.ghostty;
  };

  home.pointerCursor = {
    name = "Future-cursors";
    package = pkgs.future-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.sessionVariables = {
    XCURSOR_THEME = "Future-cursors";
    XCURSOR_SIZE = "24";
  };

}
