terraform {
  required_version = ">= 1.9"
}

locals {
  flake    = "/home/gumbo/nixos"
  machines = "/home/gumbo/nixos/machines"
  ssh_key  = file("/home/gumbo/.ssh/temp")
}
