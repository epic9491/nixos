{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.home-manager.enable = true;

  home = {
    username = "gumbo";
    homeDirectory = lib.mkForce "/home/gumbo";
    stateVersion = "25.05";
  };

  programs.git = {
    enable = true;
    package = pkgs.git;
    settings = {
      core.editor = "nvim";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "tokyo-night";
      theme_background = true;
      truecolor = true;
    };
  };

  xdg.configFile = {
    "starship.toml".source = ../config/starship/starship.server.toml;
  };

}
