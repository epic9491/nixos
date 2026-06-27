{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.chromium.override { enableWideVine = true; })
  ];

  programs.chromium = {
    enable = true;
    extraOpts = {
      "WebAppInstallForceList" = [
        {
          "url" = "https://netflix.com";
          "default_launch_container" = "window";
          "create_desktop_shortcut" = true;
        }
        {
          "url" = "https://play.hbomax.com";
          "default_launch_container" = "window";
          "create_desktop_shortcut" = true;
        }
        {
          "url" = "https://peacocktv.com";
          "default_launch_container" = "window";
          "create_desktop_shortcut" = true;
        }
        {
          "url" = "https://tv.apple.com";
          "default_launch_container" = "window";
          "create_desktop_shortcut" = true;
        }
        {
          "url" = "https://jellyfin-v2.zorse-ruffe.ts.net";
          "default_launch_container" = "window";
          "create_desktop_shortcut" = true;
        }
      ];
    };
  };
}
