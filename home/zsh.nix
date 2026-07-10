{
  config,
  pkgs,
  lib,
  hostName,
  ...
}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    shellAliases = {
      ls = "eza";
      battery-health = "upower -i /org/freedesktop/UPower/devices/battery_BAT0";
      lz = "lazyssh";
      yz = "yazi";
      borg_backup = "systemctl restart borgbackup-job-${hostName}-home";
      borg_logs = "journalctl -u borgbackup-job-${hostName}-home";
      port_forward = "while true ; do date ; natpmpc -a 1 0 udp 60 -g 10.2.0.1 && natpmpc -a 1 0 tcp 60 -g 10.2.0.1 || { echo -e 'ERROR with natpmpc command \a' ; break ; } ; sleep 45 ; done";
    };
    initContent = lib.mkMerge [
      (lib.mkOrder 1000 ''
        export EZA_CONFIG_DIR="$HOME/.config/eza"
        export EZA_ICONS_AUTO=1
      '')
      (lib.mkOrder 1500 ''
        eval "$(${pkgs.starship}/bin/starship init zsh)"
      '')
    ];
    history.size = 10000;
    oh-my-zsh = {
      enable = true;
      package = pkgs.oh-my-zsh;
      plugins = [
        "autojump"
        "terraform"
      ];
    };
  };
}
