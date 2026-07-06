{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "svc" ''
      set -euo pipefail

      if [ "$#" -lt 1 ]; then
        echo "usage: svc <service-account> [command...]" >&2
        exit 1
      fi

      user="$1"
      shift

      bash="/run/current-system/sw/bin/bash"
      machinectl="/run/current-system/sw/bin/machinectl"

      if [ "$#" -eq 0 ]; then
        exec "$machinectl" shell "''${user}@" "$bash" -l
      else
        exec "$machinectl" shell "''${user}@" "$bash" -lc '"$@"' bash "$@"
      fi
    '')
  ];
}
