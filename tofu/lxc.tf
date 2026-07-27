# LXC template. The container already exists and boots the NixOS LXC image, so
# there is no disko step: build the closure locally, then nixos-rebuild onto it.
#
# 1. cp lxc.tf <host>.tf
# 2. uncomment, replace HOST and the ipv4
# 3. nix run nixpkgs#opentofu -- init && nix run nixpkgs#opentofu -- apply
# 4. rm <host>.tf before staging anything
#
# Host prep first: nesting on, subuid/subgid width for the idmap, and any
# kernel module the guest needs loaded on the Proxmox node.

# locals {
#   HOST_ipv4 = "192.168.0.x"
# }
#
# module "HOST_system" {
#   source    = "github.com/nix-community/nixos-anywhere//terraform/nix-build"
#   attribute = "${local.flake}#nixosConfigurations.HOST.config.system.build.toplevel"
# }
#
# module "deploy_HOST" {
#   source          = "github.com/nix-community/nixos-anywhere//terraform/nixos-rebuild"
#   nixos_system    = module.HOST_system.result.out
#   target_host     = local.HOST_ipv4
#   ssh_private_key = local.ssh_key
# }
