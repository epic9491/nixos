locals {
  jellyfin_ipv4 = ""
}

module "jellyfin_system" {
  source    = "github.com/nix-community/nixos-anywhere//terraform/nix-build"
  attribute = "/home/gumbo/nixos#nixosConfigurations.jellyfin.config.system.build.toplevel"
}

module "deploy_jellyfin" {
  source          = "github.com/nix-community/nixos-anywhere//terraform/nixos-rebuild"
  nixos_system    = module.jellyfin_system.result.out
  target_host     = local.jellyfin_ipv4
  ssh_private_key = file("/home/gumbo/.ssh/temp")
}
