locals {
  pangolin_ipv4 = ""
}

module "deploy_pangolin" {
  source                 = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"
  nixos_system_attr      = "/home/gumbo/nixos#nixosConfigurations.pangolin.config.system.build.toplevel"
  nixos_partitioner_attr = "/home/gumbo/nixos#nixosConfigurations.pangolin.config.system.build.diskoScript"
  target_host            = local.pangolin_ipv4
  instance_id            = local.pangolin_ipv4
  debug_logging              = true
  build_on_remote            = false
  nixos_generate_config_path = "/home/gumbo/nixos/machines/server/pangolin/hardware-configuration.nix"
  install_ssh_key            = file("/home/gumbo/.ssh/temp")
  deployment_ssh_key         = file("/home/gumbo/.ssh/temp")
}
