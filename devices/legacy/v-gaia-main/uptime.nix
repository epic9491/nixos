{ config, inputs, ... }:
{
  containers.uptime = {
    autoStart = true;
    config = { config, pkgs, ... }: {
      system.stateVersion = "25.11";
      nixpkgs.overlays = [
        (final: prev: {
          unstable = import inputs.nixpkgs-unstable {
            system = prev.system;
            config.allowUnfree = true;
          };
        })
      ];
      services.uptime-kuma = {
        enable = true;
        appriseSupport = true;
        package = pkgs.unstable.uptime-kuma;
        settings = {
          UPTIME_KUMA_HOST = "127.0.0.1";
        };
      };
    };
  };
}
