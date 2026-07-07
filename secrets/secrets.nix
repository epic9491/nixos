let
  secret-mgmt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMvYIo3MxF2XpAhMjZ/T6NfI+PAlB8GDrZ11xjH5uVb gumbo@nixos";
  console = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKwFGIeJCte8DLdoBmE7Q8FYhTWazkVLMwq6B/6hadd8 gumbo@console";
  srv-n1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINSDR29Go5nMlk58JRcYWM3qNET5tUP1/0jdNPBh6x2S gumbo@srv-n1";
  mongoose = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPdNVyjeIcJlgDYBSdvVmdNVpzp9RCr7b9NDTA69Uw+ gumbo@mongoose";
  k3s-s1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGUVBtM6haqazKIi6nYx3KF+1N1OliHW+KjQDLqEdLzO gumbo@k3s-s1";
  k3s-a1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAK9uDYiTln0BcPYwzHFCUur2ZG50G/410N8qCqSU7PT gumbo@k3s-a1";
  k3s-a2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQRa7a94RT7Fs/jmToF0vfAtSJRJ8ZoAWuVoWsQjGbN gumbo@k3s-a2";
  k3s-a3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICd1/b3nt1jYmBaAglIYb0DsAaKkj3ebxqDnB+5eBlgW gumbo@k3s-a3";
  k3s-a4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAV6SDEW82ZvzRKRZlqd2hw9ticKDMEAdtVAbmMHup+z gumbo@k3s-a4";
  all-systems = [
    secret-mgmt
    console
    k3s-s1
    k3s-a1 
    k3s-a2 
    k3s-a3 
    k3s-a4 
    srv-n1
  ];
  k3s = [ 
    secret-mgmt 
    k3s-s1 
    k3s-a1 
    k3s-a2 
    k3s-a3 
    k3s-a4 
  ];
in
{
  "test.age".publicKeys = all-systems;
  "k3s-token.age".publicKeys = k3s;
  "k3s-ts-auth.age".publicKeys = k3s;
  "newt-auth.age".publicKeys = [ secret-mgmt k3s-s1 ];
  "influx-auth-s1.age".publicKeys = [ secret-mgmt k3s-s1 ];
  "grafana-auth-s1.age".publicKeys = [ secret-mgmt k3s-s1 ];
  "grafana-datasources-s1.age".publicKeys = [ secret-mgmt k3s-s1 ];
  "wg0.age".publicKeys = [ secret-mgmt mongoose ];
  "pbs.console.age".publicKeys = [ secret-mgmt console ];
  "pbs.srv-n1.age".publicKeys = [ secret-mgmt srv-n1 ];
  "pbs.srv-n1.key.age".publicKeys = [ secret-mgmt srv-n1 ];
  "srv-n1.newt.env.age".publicKeys = [ secret-mgmt srv-n1 ];
  "srv-n1.karakeep.env.age".publicKeys = [ secret-mgmt srv-n1 ];
  "srv-n1.vaultwarden.env.age".publicKeys = [ secret-mgmt srv-n1 ];
  "srv-n1.immich.env.age".publicKeys = [ secret-mgmt srv-n1 ];
  "srv-n1.immich-public.env.age".publicKeys = [ secret-mgmt srv-n1 ];
  "srv-n1.caddy.env.age".publicKeys = [ secret-mgmt srv-n1 ];
  "srv-n1.cockpit.env.age".publicKeys = [ secret-mgmt srv-n1 ];
  "srv-n1.searxng.env.age".publicKeys = [ secret-mgmt srv-n1 ];
  "srv-n1.obsidian-couchdb.env.age".publicKeys = [ secret-mgmt srv-n1 ];
  "srv-n1.obsidian-cloudflared.env.age".publicKeys = [ secret-mgmt srv-n1 ];
}
