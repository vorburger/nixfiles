let
  keys = (import ./recipients.nix).recipients;
in
{
  "encrypted/hello.age".publicKeys = builtins.attrValues keys;
}
