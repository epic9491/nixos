let
  secret-mgmt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMvYIo3MxF2XpAhMjZ/T6NfI+PAlB8GDrZ11xjH5uVb gumbo@nixos";
  seed = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQCpz0YViCu28wuI30HiOFBKld/sAAfwKDSGK2W2+J5 gumbo@seed";
  v-null = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDK/9uPYOJkAqnA8HVAr+g0aThRP4N8bFd9erpAMMCZY gumbo@null";
  k3s-s1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGUVBtM6haqazKIi6nYx3KF+1N1OliHW+KjQDLqEdLzO gumbo@k3s-s1";
  k3s-a1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAK9uDYiTln0BcPYwzHFCUur2ZG50G/410N8qCqSU7PT gumbo@k3s-a1";
  k3s-a2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQRa7a94RT7Fs/jmToF0vfAtSJRJ8ZoAWuVoWsQjGbN gumbo@k3s-a2";
  k3s-a3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICd1/b3nt1jYmBaAglIYb0DsAaKkj3ebxqDnB+5eBlgW gumbo@k3s-a3";
  k3s-a4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAV6SDEW82ZvzRKRZlqd2hw9ticKDMEAdtVAbmMHup+z gumbo@k3s-a4";
  all-systems = [ 
    secret-mgmt 
    seed 
    k3s-s1 
    k3s-a1 
    k3s-a2 
    k3s-a3 
    k3s-a4 
    v-null 
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
  "wg0.age".publicKeys = [ secret-mgmt seed null ];
}
