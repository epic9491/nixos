{
  imports = [
    ../../../modules/baseline.lxc.nix
    ./containers
    ./tailscale.nix
  ];

  networking.hostName = "jellyfin";
}
