locals {
  second_brain_ipv4 = ""
}

module "second_brain_system" {
  source    = "github.com/nix-community/nixos-anywhere//terraform/nix-build"
  attribute = "/home/gumbo/nixos#nixosConfigurations.second-brain.config.system.build.toplevel"
}

module "deploy_second_brain" {
  source          = "github.com/nix-community/nixos-anywhere//terraform/nixos-rebuild"
  nixos_system    = module.second_brain_system.result.out
  target_host     = local.second_brain_ipv4
  ssh_private_key = file("/home/gumbo/.ssh/temp")
}
