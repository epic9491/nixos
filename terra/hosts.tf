locals {
  flake   = "/home/gumbo/nixos"
  ssh_key = file("/home/gumbo/.ssh/temp")

  hosts = {
    console     = { ip = "192.168.0.175", dir = "machines/desktop/console" }
    git         = { ip = "", dir = "machines/server/git" }
    k3s-a1      = { ip = "192.168.0.133", dir = "machines/server/k3s/k3s-a1" }
    k3s-a2      = { ip = "192.168.0.244", dir = "machines/server/k3s/k3s-a2" }
    k3s-a3      = { ip = "192.168.0.134", dir = "machines/server/k3s/k3s-a3" }
    k3s-a4      = { ip = "192.168.0.223", dir = "machines/server/k3s/k3s-a4" }
    k3s-s1      = { ip = "192.168.0.43", dir = "machines/server/k3s/k3s-s1" }
    mongoose    = { ip = "192.168.0.191", dir = "machines/server/mongoose" }
    pangolin    = { ip = "", dir = "machines/server/pangolin" }
    secret-mgmt = { ip = "192.168.0.209", dir = "machines/server/secret-mgmt" }
    srv-n1      = { ip = "192.168.0.38", dir = "machines/server/srv-n1", luks_script = "/home/gumbo/.secrets/srv-n1-luks.sh" }
    srv-n2      = { ip = "", dir = "machines/server/srv-n2" }
    zeus        = { ip = "192.168.0.157", stop_after_disko = true }
  }

  lxc_hosts = {
    jellyfin = { ip = "" }
    runner   = { ip = "" }
  }
}

module "deploy" {
  for_each               = local.hosts
  source                 = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"
  nixos_system_attr      = "${local.flake}#nixosConfigurations.${each.key}.config.system.build.toplevel"
  nixos_partitioner_attr = "${local.flake}#nixosConfigurations.${each.key}.config.system.build.diskoScript"
  target_host            = each.value.ip
  instance_id            = each.value.ip
  debug_logging          = true
  build_on_remote        = false
  stop_after_disko       = try(each.value.stop_after_disko, false)
  nixos_generate_config_path = (
    try(each.value.dir, null) != null
    ? "${local.flake}/${each.value.dir}/hardware-configuration.nix"
    : ""
  )
  install_ssh_key    = local.ssh_key
  deployment_ssh_key = local.ssh_key
  disk_encryption_key_scripts = (
    try(each.value.luks_script, null) != null
    ? [{ path = "/tmp/disk.key", script = each.value.luks_script }]
    : []
  )
}

module "lxc_system" {
  for_each  = local.lxc_hosts
  source    = "github.com/nix-community/nixos-anywhere//terraform/nix-build"
  attribute = "${local.flake}#nixosConfigurations.${each.key}.config.system.build.toplevel"
}

module "deploy_lxc" {
  for_each        = local.lxc_hosts
  source          = "github.com/nix-community/nixos-anywhere//terraform/nixos-rebuild"
  nixos_system    = module.lxc_system[each.key].result.out
  target_host     = each.value.ip
  ssh_private_key = local.ssh_key
}
