locals {
  k3-2_ipv4 = "0.0.0.0"
}

module "deploy_k3-2" {
  source                 = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"
  nixos_system_attr      = "/home/gumbo/nixos#nixosConfigurations.k3-2.config.system.build.toplevel"
  nixos_partitioner_attr = "/home/gumbo/nixos#nixosConfigurations.k3-2.config.system.build.diskoScript"
  target_host            = local.k3-2_ipv4
  instance_id            = local.k3-2_ipv4
  debug_logging          = true
  build_on_remote        = false
  stop_after_disko       = true
  install_ssh_key        = file("/home/gumbo/.ssh/temp")
}
