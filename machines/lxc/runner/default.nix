{
  imports = [
    ../../../modules/baseline.lxc.nix
    ./runner.nix
    ./harmonia.nix
  ];

  networking.hostName = "runner";

  # enabled gives runner too much reach
  server.cd.enable = false;
}
