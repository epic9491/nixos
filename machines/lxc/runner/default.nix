{
  imports = [
    ../../../modules/baseline.lxc.nix
    ./runner.nix
  ];

  networking.hostName = "runner";
}
