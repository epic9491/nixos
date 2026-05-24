locals {
  secret-mgmt_ipv4 = "192.168.0.209"
}

module "deploy_secret-mgmt" {
  source                 = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"
  nixos_system_attr      = "/home/gumbo/nixos#nixosConfigurations.secret-mgmt.config.system.build.toplevel"
  nixos_partitioner_attr = "/home/gumbo/nixos#nixosConfigurations.secret-mgmt.config.system.build.diskoScript"
  target_host            = local.secret-mgmt_ipv4
  instance_id            = local.secret-mgmt_ipv4
  debug_logging              = true
  build_on_remote            = false
  nixos_generate_config_path = "/home/gumbo/nixos/devices/server/vms/secret-mgmt/hardware-configuration.nix"
  install_ssh_key            = file("/home/gumbo/.ssh/temp")
  deployment_ssh_key         = file("/home/gumbo/.ssh/temp")
}
