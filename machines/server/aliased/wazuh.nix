{ inputs, ... }:
{
  imports = [ inputs.wazuh-agent.nixosModules.wazuh-agent ];

  services.wazuh-agent = {
    enable = true;

    # magicdns is off on servers, baseline.server.nix resolves this name
    manager.host = "wazuh.zorse-ruffe.ts.net";

    # /bin and /usr/sbin hold nothing on nixos, so watch the mutable surface
    syscheck.directories = [
      "/etc"
      "/boot"
      "/root"
      "/home"
    ];

    labels.role = "aliased";
  };
}
