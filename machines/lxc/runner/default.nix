{
  imports = [
    ../../../modules/baseline.lxc.nix
    ./runner.nix
    ./harmonia.nix
  ];

  networking.hostName = "runner";
}
