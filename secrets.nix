let
  keys = (import ./recipients.nix).recipients;
in
{
  "encrypted/hello-secret.age".publicKeys = builtins.attrValues keys;
}
