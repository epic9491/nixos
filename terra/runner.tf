locals {
  runner_ipv4 = ""
}

module "runner_system" {
  source    = "github.com/nix-community/nixos-anywhere//terraform/nix-build"
  attribute = "/home/gumbo/nixos#nixosConfigurations.runner.config.system.build.toplevel"
}

module "deploy_runner" {
  source          = "github.com/nix-community/nixos-anywhere//terraform/nixos-rebuild"
  nixos_system    = module.runner_system.result.out
  target_host     = local.runner_ipv4
  ssh_private_key = file("/home/gumbo/.ssh/temp")
}
