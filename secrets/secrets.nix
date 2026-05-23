let
  secret-mgmt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMvYIo3MxF2XpAhMjZ/T6NfI+PAlB8GDrZ11xjH5uVb gumbo@nixos";
  zeus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/xhPKIy6eFgVXgMPsGkzjDUxuJJP3oEWutvK49lIPu gumbo@zeus";
  systems = [ secret-mgmt zeus ];
  k3s = [ secret-mgmt zeus ];
in
{
  "test.age".publicKeys = systems;
  "k3s-token.age".publicKeys = k3s;
}
