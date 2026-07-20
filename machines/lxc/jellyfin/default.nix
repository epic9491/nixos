{
  imports = [
    ../../../modules/baseline.lxc.nix
    ./containers
    ./tailscale.nix
  ];

  networking.hostName = "jellyfin";

  server.cache.enable = true;
}
