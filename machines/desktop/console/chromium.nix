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
          "url" = "https://www.netflix.com/";
          "default_launch_container" = "window";
          "create_desktop_shortcut" = true;
        }
        {
          "url" = "https://play.hbomax.com";
          "default_launch_container" = "window";
          "create_desktop_shortcut" = true;
        }
        {
          "url" = "https://www.peacocktv.com/watch/home";
          "default_launch_container" = "window";
          "create_desktop_shortcut" = true;
        }
        {
          "url" = "https://tv.apple.com";
          "default_launch_container" = "window";
          "create_desktop_shortcut" = true;
        }
        {
          "url" = "https://jellyfin.zorse-ruffe.ts.net";
          "default_launch_container" = "window";
          "create_desktop_shortcut" = true;
        }
      ];
    };
  };
}
