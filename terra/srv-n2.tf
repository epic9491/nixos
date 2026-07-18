locals {
  srv-n2_ipv4 = ""
}

module "deploy_srv-n2" {
  source                 = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"
  nixos_system_attr      = "/home/gumbo/nixos#nixosConfigurations.srv-n2.config.system.build.toplevel"
  nixos_partitioner_attr = "/home/gumbo/nixos#nixosConfigurations.srv-n2.config.system.build.diskoScript"
  target_host            = local.srv-n2_ipv4
  instance_id            = local.srv-n2_ipv4
  debug_logging              = true
  build_on_remote            = false
  nixos_generate_config_path = "/home/gumbo/nixos/machines/server/srv-n2/hardware-configuration.nix"
  install_ssh_key            = file("/home/gumbo/.ssh/temp")
  deployment_ssh_key         = file("/home/gumbo/.ssh/temp")
}
