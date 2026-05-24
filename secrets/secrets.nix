let
  secret-mgmt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMvYIo3MxF2XpAhMjZ/T6NfI+PAlB8GDrZ11xjH5uVb gumbo@nixos";
  k3s-s1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/xhPKIy6eFgVXgMPsGkzjDUxuJJP3oEWutvK49lIPu gumbo@zeus";
  k3s-a1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF4AawMOe7HKxlu1phyLc7iDyWIVFdhoeZEffzaNqdfr gumbo@k3-1";
  k3s-a2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIcYW42Db38mYMDZ0VgTjAX/V6wnla4yleOEWggL7a16 gumbo@k3-2";
  all-systems = [ secret-mgmt k3s-s1 k3s-a1 k3s-a2 ];
  k3s = [ secret-mgmt k3s-s1 k3s-a1 k3s-a2 ];
in
{
  "test.age".publicKeys = all-systems;
  "k3s-token.age".publicKeys = k3s;
}
