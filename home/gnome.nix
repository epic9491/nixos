{
  config,
  pkgs,
  lib,
  ...
}:

{

  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
    theme = {
      name = "Tokyonight-Dark";
      package = pkgs.tokyonight-gtk-theme;
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

  xdg.configFile."gtk-4.0/gtk.css".force = true;

  home.pointerCursor = {
    name = "BreezeX-RosePine-Linux";
    package = pkgs.rose-pine-cursor;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.sessionVariables = {
    XCURSOR_THEME = "BreezeX-RosePine-Linux";
    XCURSOR_SIZE = "24";
    QT_QPA_PLATFORMTHEME = "gtk3";
  };

}
