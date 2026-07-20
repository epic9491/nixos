{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (builtins.pathExists ../../../secrets/runner.token) {
    sops.secrets."runner.token" = {
      sopsFile = ../../../secrets/runner.token;
      format = "binary";
    };

    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances.nix = {
        enable = true;
        name = "runner";
        url = "https://git.zorse-ruffe.ts.net";
        tokenFile = config.sops.secrets."runner.token".path;
        labels = [ "nix:host" ];
        hostPackages = with pkgs; [
          bash
          coreutils
          curl
          diffutils
          gawk
          git
          gnused
          jq
          nix
          nodejs
          python3
          wget
        ];
      };
    };
  };
}
