locals {
  mongoose_ipv4 = "192.168.0.192"
}

module "deploy_mongoose" {
  source                 = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"
  nixos_system_attr      = "/home/gumbo/nixos#nixosConfigurations.mongoose.config.system.build.toplevel"
  nixos_partitioner_attr = "/home/gumbo/nixos#nixosConfigurations.mongoose.config.system.build.diskoScript"
  target_host            = local.mongoose_ipv4
  instance_id            = local.mongoose_ipv4
  debug_logging              = true
  build_on_remote            = false
  nixos_generate_config_path = "/home/gumbo/nixos/devices/server/mongoose/hardware-configuration.nix"
  install_ssh_key            = file("/home/gumbo/.ssh/temp")
  deployment_ssh_key         = file("/home/gumbo/.ssh/temp")
}
