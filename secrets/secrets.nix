let
  secret-mgmt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMvYIo3MxF2XpAhMjZ/T6NfI+PAlB8GDrZ11xjH5uVb gumbo@nixos";
  k3s-s1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGUVBtM6haqazKIi6nYx3KF+1N1OliHW+KjQDLqEdLzO gumbo@k3s-s1";
  k3s-a1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAK9uDYiTln0BcPYwzHFCUur2ZG50G/410N8qCqSU7PT gumbo@k3s-a1";
  k3s-a2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQRa7a94RT7Fs/jmToF0vfAtSJRJ8ZoAWuVoWsQjGbN gumbo@k3s-a2";
  all-systems = [ secret-mgmt k3s-s1 k3s-a1 k3s-a2 ];
  k3s = [ secret-mgmt k3s-s1 k3s-a1 k3s-a2 ];
in
{
  "test.age".publicKeys = all-systems;
  "k3s-token.age".publicKeys = k3s;
}
