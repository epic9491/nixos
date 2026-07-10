{
  config,
  pkgs,
  lib,
  hostName,
  ...
}:
let
  niriConfig =
    if hostName == "prometheus" then
      ../config/niri/config.laptop.kdl
    else
      ../config/niri/config.desktop.kdl;
in
{
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
      "gtk-application-prefer-dark-theme" = true;
    };

    gtk4.extraConfig = {
      "gtk-application-prefer-dark-theme" = true;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "Fusion";
  };

  xdg.configFile = {
    "gtk-3.0/settings.ini".force = true;
    "gtk-4.0/settings.ini".force = true;
    "gtk-4.0/gtk.css".force = true;
    "niri/config.kdl".source = niriConfig;
    "niri/noctalia.kdl".source = ../config/niri/noctalia.kdl;
    "ghostty/config".source = ../config/ghostty/tokyo-night.ghostty;
  };

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
    NIXOS_OZONE_WL = "1";
    ICON_THEME = "Papirus";
    QS_ICON_THEME = "Papirus";
  };
}
