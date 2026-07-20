{
  config,
  lib,
  ...
}:

{
  config = lib.mkIf (builtins.pathExists ../../../secrets/runner.cache-key) {
    sops.secrets."runner.cache-key" = {
      sopsFile = ../../../secrets/runner.cache-key;
      format = "binary";
    };

    services.harmonia.cache = {
      enable = true;
      signKeyPaths = [ config.sops.secrets."runner.cache-key".path ];
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 5000 ];
  };
}
