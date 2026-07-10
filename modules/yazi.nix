{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.workstation.yazi;
in
{

  options.workstation.yazi.enable = lib.mkEnableOption "Yazi configuration";

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      settings = {
        yazi = {
          ratio = [
            1
            4
            3
          ];
          sort_by = "natural";
          sort_sensitive = true;
          sort_reverse = false;
          sort_dir_first = true;
          linemode = "none";
          show_hidden = true;
          show_symlink = true;
        };
      };
    };
  };
}
