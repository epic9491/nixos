{
  config,
  lib,
  ...
}:
let
  cfg = config.server.cache;
  pubKeyFile = ../secrets/runner.cache-key.pub;
in
{
  options.server.cache.enable = lib.mkEnableOption "Substitute from the runner binary cache";

  config = lib.mkIf (cfg.enable && builtins.pathExists pubKeyFile) {
    nix.settings = {
      extra-substituters = [ "http://100.69.69.219:5000" ];
      extra-trusted-public-keys = [ (lib.removeSuffix "\n" (builtins.readFile pubKeyFile)) ];
      connect-timeout = 5;
    };
  };
}
