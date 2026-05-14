{ self, ... }:
{
  imports = [
    self.nixosModules.zfs
    ../services/_networking.nix
    ../services/_openssh.nix
    ../services/_nix.nix
  ];
}
