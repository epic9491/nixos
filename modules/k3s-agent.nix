{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cluster.k3sAgent;
in
{
  options.cluster.k3sAgent = {
    enable = lib.mkEnableOption "k3s agent node";
    serverAddr = lib.mkOption {
      type = lib.types.str;
      description = "Address of the k3s server";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [ 8472 ]; # Flannel

    services.tailscale.authKeyFile = "/run/secrets/k3s-ts-auth";

    services.k3s = {
      enable = true;
      role = "agent";
      tokenFile = "/run/secrets/k3s-token";
      serverAddr = cfg.serverAddr;
      gracefulNodeShutdown.enable = true;
    };

    sops.secrets."k3s-token" = {
      sopsFile = ../secrets/k3s-token;
      format = "binary";
      owner = "root";
      group = "root";
      mode = "0400";
    };

    sops.secrets."k3s-ts-auth" = {
      sopsFile = ../secrets/k3s-ts-auth;
      format = "binary";
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };
}
