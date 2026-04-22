locals {
  zeus_ipv4 = "192.168.0.157"
}

module "deploy_zeus" {
  source                 = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"
  nixos_system_attr      = "/home/gumbo/nixos#nixosConfigurations.zeus.config.system.build.toplevel"
  nixos_partitioner_attr = "/home/gumbo/nixos#nixosConfigurations.zeus.config.system.build.diskoScript"
  target_host            = local.zeus_ipv4
  instance_id            = local.zeus_ipv4
  debug_logging          = true
  build_on_remote        = false
  stop_after_disko       = true
  install_ssh_key        = file("/home/gumbo/.ssh/temp")
}
