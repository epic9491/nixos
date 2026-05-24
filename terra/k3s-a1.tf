locals {
  k3s-a1_ipv4 = "192.168.0.133"
}
module "deploy_k3s-a1" {
  source                 = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"
  nixos_system_attr      = "/home/gumbo/nixos#nixosConfigurations.k3s-a1.config.system.build.toplevel"
  nixos_partitioner_attr = "/home/gumbo/nixos#nixosConfigurations.k3s-a1.config.system.build.diskoScript"
  target_host            = local.k3s-a1_ipv4
  instance_id            = local.k3s-a1_ipv4
  debug_logging              = true
  build_on_remote            = false
  nixos_generate_config_path = "/home/gumbo/nixos/devices/server/vms/k3s-a1/hardware-configuration.nix"
  install_ssh_key            = file("/home/gumbo/.ssh/temp")
  deployment_ssh_key         = file("/home/gumbo/.ssh/temp")
}
