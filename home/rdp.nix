{ pkgs, ... }:

{
  xdg.configFile."krdpserverrc".text = ''
    [General]
    SystemUserEnabled=true
  '';

  systemd.user.services."krdp-authorize-portal" = {
    Unit = {
      Description = "Pre-authorize KRDP server with the xdg-desktop-portal permission store";
      Before = [ "app-org.kde.krdpserver.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/busctl --user call org.freedesktop.impl.portal.PermissionStore /org/freedesktop/impl/portal/PermissionStore org.freedesktop.impl.portal.PermissionStore SetPermission sbssas kde-authorized true remote-desktop org.kde.krdpserver 1 yes";
    };
    Install.WantedBy = [ "plasma-workspace.target" ];
  };

  systemd.user.services."app-org.kde.krdpserver" = {
    Unit = {
      Description = "KRDP Server";
      After = [
        "plasma-xdg-desktop-portal-kde.service"
        "plasma-core.target"
        "krdp-authorize-portal.service"
      ];
      Wants = [ "krdp-authorize-portal.service" ];
    };
    Service = {
      Type = "exec";
      ExecStart = "${pkgs.kdePackages.krdp}/bin/krdpserver";
      Restart = "on-abnormal";
      NoNewPrivileges = true;
    };
    Install.WantedBy = [ "plasma-workspace.target" ];
  };
}
